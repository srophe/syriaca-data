xquery version "3.0";
(:
 : Convert TEI to triples as defined by the syriaca.org project
:)
declare namespace srophe = "https://srophe.app";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/turtle";
declare option output:indent "yes";
(:method=text media-type=text/turtle indent=yes:)

(:~
 : Create an RDF URI
 : @param $uri uri/id as xs:string 
 :)
declare function local:make-uri($uri){
    concat('<',normalize-space($uri),'>')
};

(:~ 
 : Build literal string, normalize spaces and strip "", add lang if specified
 : @param $string string for literal
 : @param $lang language code as xs:string  
 :)
declare function local:make-literal($string as xs:string*, $lang as xs:string*, $datatype as xs:string?) as xs:string?{
    concat('"',replace(normalize-space(string-join($string,' ')),'"',''),'"',
        if($lang != '') then 
            let $langString := 
                if(contains($lang,'-')) then substring-before($lang,'-')
                else if(contains($lang,'en')) then 'en'
                else if(contains($lang,'syr')) then 'syr'
                else $lang
            return concat('@',$langString) 
        else (), 
        if($datatype != '') then concat('^^',$datatype) else()) 
};

(:~ 
 : Build basic triple string, output as string. 
 : @param $s triple subject
 : @param $o triple object
 : @param $p triple predicate
 :)
declare function local:make-triple($s as xs:string?, $o as xs:string?, $p as xs:string?) as xs:string* {
    concat('&#xa;', $s,' ', $o,' ', $p, ' .')
};

(: Create dates :)
declare function local:make-date($date){
    if($date castable as xs:dateTime) then 
        local:make-literal($date, (),'xsd:dateTime')
    else if($date castable as xs:gYearMonth) then
        local:make-literal($date, (),'xsd:gYearMonth')
    else if($date castable as xs:date) then 
        local:make-literal($date, (),'xsd:date')                        
    else if($date castable as xs:gYear) then 
        local:make-literal($date, (),'xsd:gYear')
    else if($date castable as xs:gMonthDay) then 
        local:make-literal($date, (),'xsd:gMonthDay')
    else local:make-literal($date, (),())        
};

declare function local:rec-type($node){
    if($node/descendant::tei:body/tei:listPerson) then
        'lawd:Person'
    else if($node/descendant::tei:body/tei:listPlace) then
        'lawd:Place'
    else if($node/descendant::tei:body/tei:bibl[@type="lawd:ConceptualWork"]) then
        'lawd:conceptualWork'
    else if($node/descendant::tei:body/tei:biblStruct) then
        'dcterms:bibliographicResource'        
    else if($node/tei:listPerson) then
       'syriaca:personFactoid'    
    else if($node/tei:listEvent) then
        'syriaca:eventFactoid'
    else if($node/tei:listRelation) then
        'syriaca:relationFactoid'
    else()
};

declare function local:make-triple-set($node){
let $idno := ($node/descendant::tei:idno[@type='URI'], $node/descendant::tei:idno)[1]
let $id := if(ends-with($idno,'/tei')) then replace($idno,'/tei','') else $idno
let $type := local:rec-type($node)
let $typeShort := tokenize($type,':')[last()]
let $idShort := tokenize($id,'/')[last()]
return 
    if($type = 'lawd:Person') then 
        (
        local:make-triple(local:make-uri($id), 'rdf:type', local:rec-type($node)),
        local:persons($node, $id, $idShort, $typeShort)
        )
    else if($type = 'lawd:Place') then 
        (
        local:make-triple(local:make-uri($id), 'rdf:type', local:rec-type($node)),
        local:places($node, $id, $idShort, $typeShort)
        )        
    else local:make-triple(local:make-uri($id), 'rdf:type', local:rec-type($node))
};

declare function local:places($node, $id, $idShort, $typeShort){
(
(:Series statement:)
    for $series in $node/descendant::tei:seriesStmt
    return local:make-triple(local:make-uri($id), 'rdfs:partOf', local:make-uri($series/tei:idno/text())),
(: RDFs Label from headwords:)
    for $headword in $node/descendant::tei:place/tei:placeName[@srophe:tags='#syriaca-headword']
    let $lang := $headword/@xml:lang
    return local:make-triple(local:make-uri($id), 'rdfs:label', local:make-literal($headword/descendant-or-self::text(),$lang,'')),
(: hasCitation - bibl referenes :)
    for $citation in $node/descendant::tei:bibl/tei:ptr/@target[contains(., 'syriaca.org/')]
    return local:make-triple(local:make-uri($id), 'lawd:hasCitation', local:make-uri($citation)),
(:primaryTopicOf idno in publication statement :)
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.tei'))),
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.html'))),
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.ttl'))),
(: dcterms:hasFormat idno in publication statement :)
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.tei'))),
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.html'))),
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.ttl'))),
(: Description/abstract :)
    for $note in $node/descendant::tei:note[@type='abstract']
    return local:make-triple(local:make-uri($id), 'schema:description', local:make-literal($note/descendant-or-self::text(),$note/@xml:lang,'')),
    for $note in $node/descendant::tei:desc[@type='abstract']
    return local:make-triple(local:make-uri($id), 'schema:description', local:make-literal($note/descendant-or-self::text(),$note/@xml:lang,'')),
(:WS:NOTE literal does not work
    Description/abstract as an XML literal
    for $note in $node/descendant::tei:note[@type='abstract']
    return local:make-triple('', 'rdfs:XMLLiteral', concat('"',$note/self::*,'"')),
    :) 
(: Place type :)
    for $placeType at $p in tokenize($node/descendant::tei:place/@ana,' ')
    let $ana := 
        if(starts-with($placeType,'http')) then
            local:make-uri($placeType)
        else concat('swd:',$placeType)
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:place-type', $ana),
        local:make-triple(local:make-uri($id), 'sp:place-type', concat('swds:place-type-',$idShort, '-',$p)),
        local:make-triple(concat('swds:place-type-',$idShort, '-',$p), 'sps:place-type', $ana),
        local:make-triple(concat('swds:place-type-',$idShort, '-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: relations :)
    let $relPersons := distinct-values($node/descendant::tei:text/descendant::tei:persName/@ref)
    for $relPers in $relPersons[. != $id]
    return local:make-triple(local:make-uri($id), 'dcterms:relation', local:make-uri($relPers)),
    let $relPlaces := distinct-values($node/descendant::tei:text/descendant::tei:placeName/@ref)
    for $relPlace in $relPlaces[. != $id]
    return local:make-triple(local:make-uri($id), 'dcterms:relation', local:make-uri($relPlace)),

(: Name varients :)
    for $nameVariant in $node/descendant::tei:place/tei:placeName 
    return local:make-triple(local:make-uri($id), 'swdt:name-variant', local:make-literal($nameVariant/descendant-or-self::text(),$nameVariant/@xml:lang,'')),
    
    (: Name variant unique statement instance :)
    for $nameVariant at $p in $node/descendant::tei:place/tei:placeName
    return 
        (local:make-triple(local:make-uri($id), 'sp:name-variant', concat('swds:',$typeShort,'-',$idShort,'-',$p)),
        local:make-triple(concat('swds:',$typeShort,'-',$idShort,'-',$p), 'sps:name-variant', local:make-literal($nameVariant/descendant-or-self::text(),$nameVariant/@xml:lang,'')),
        local:make-triple(concat('swds:',$typeShort,'-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(:IDNO :) 
    for $closeMatch at $p in $node/descendant::tei:text/descendant::tei:idno[@type ='URI'][not(contains(., "syriaca.org"))][not(contains(., "/viaf.org/viaf/"))]
    return 
        (local:make-triple(local:make-uri($id), 'swdt:closeMatch', local:make-uri($closeMatch)),
        local:make-triple(local:make-uri($id), 'sp:closeMatch', concat('swds:closeMatch-',$idShort, '-',$p)),
        local:make-triple(concat('swds:closeMatch-',$idShort, '-',$p), 'sps:closeMatch', local:make-uri($closeMatch)),
        local:make-triple(concat('swds:closeMatch-',$idShort, '-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: Events state[@type='existence']:)        
    for $event at $p in $node/descendant::tei:text/descendant::tei:state[@type='existence']
    return 
        if($event/@from != '') then
            if($event/@to) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:exist-from', local:make-date(string($event/@from))),
                local:make-triple(local:make-uri($id), 'sp:exist-from', concat('swds:exist-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:exist-from','-',$idShort,'-',$p), 'sps:exist-from', local:make-date(string($event/@from))),
                local:make-triple(concat('swds:exist-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:exist-to', local:make-date(string($event/@to))),
                local:make-triple(local:make-uri($id), 'sp:exist-to', concat('swds:exist-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:exist-to','-',$idShort,'-',$p), 'sps:exist-to', local:make-date(string($event/@to))),
                local:make-triple(concat('swds:exist-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:exist-from', local:make-date(string($event/@from))),
                local:make-triple(local:make-uri($id), 'sp:exist-from', concat('swds:exist-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:exist-from','-',$idShort,'-',$p), 'sps:exist-from', local:make-date(string($event/@from))),
                local:make-triple(concat('swds:exist-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($event/@to) then
            (
                local:make-triple(local:make-uri($id), 'swdt:exist-to', local:make-date(string($event/@to))),
                local:make-triple(local:make-uri($id), 'sp:exist-to', concat('swds:exist-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:exist-to','-',$idShort,'-',$p), 'sps:exist-to', local:make-date(string($event/@to))),
                local:make-triple(concat('swds:exist-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )        
        else (),    
(: GPS :)        
    for $gps at $p in $node/descendant::tei:text/descendant::tei:location[@type='gps']
    return
        (
            local:make-triple(local:make-uri($id), 'swdt:has-gps-coordinates', local:make-literal($gps/descendant::text(),'','geosparql:wktLiteral')),
            local:make-triple(local:make-uri($id), 'sp:has-gps-coordinates', concat('swds:coordinates','-',$idShort,'-',$p)),
            local:make-triple(local:make-uri($id), 'swd:has-gps-coordinates', local:make-literal($gps/descendant::text(),'','geosparql:wktLiteral')),
            local:make-triple(concat('swds:coordinates','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: Religious community has-religious-community  place/state[@type='confession']/@ref :)
    for $religiousCom at $p in $node/descendant::tei:text/descendant::tei:place/tei:state[@type='confession'][@ref != '']
    let $ref := $religiousCom/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:has-religious-community', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:has-religious-community', concat('swds:has-religious-community-',$idShort,'-',$p)),
        local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'sps:has-religious-community', local:make-uri($ref)),
        local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
        if($religiousCom/@when) then
            local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spq:when', local:make-date(string($religiousCom/@when)))
        else if($religiousCom/@notBefore) then 
            local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spq:not-before', local:make-date(string($religiousCom/@notBefore)))
        else if($religiousCom/@notAfter) then 
            local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spq:not-after', local:make-date(string($religiousCom/@notAfter)))
        else if($religiousCom/@from) then 
            local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spq:from', local:make-date(string($religiousCom/@from)))
        else if($religiousCom/@to) then 
            local:make-triple(concat('swds:has-religious-community-',$idShort,'-',$p), 'spq:not-to', local:make-date(string($religiousCom/@to)))
        else ()
        ),
(: Relationships :)
     for $relation at $p in $node/descendant::tei:text/descendant::tei:relation
     let $relRef := substring-after($relation/@ref,'taxonomy/')
     return (
        for $s at $ap in tokenize($relation/@active,' ')
        let $sRef := $s
        return
           for $o at $op in tokenize($relation/@passive,' ')
           let $oRef := $o
           return
               (
               local:make-triple(local:make-uri($sRef), concat('swdt:',$relRef), local:make-uri($oRef)),
               local:make-triple(local:make-uri($sRef), concat('sp:',$relRef), concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap), concat('swd:',$relRef), local:make-uri($oRef)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
               ), 
          for $s at $m1p in tokenize($relation/@mutual,' ')
          let $sRef := $s
          return   
            for $o at $m2p in tokenize($relation/@mutual,' ')[. != $s]
            let $oRef :=$o
            return 
               (
               local:make-triple(local:make-uri($sRef), concat('swdt:',$relRef), local:make-uri($oRef)),
               local:make-triple(local:make-uri($sRef), concat('sp:',$relRef), concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p), concat('swd:',$relRef), local:make-uri($oRef)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
               )
        )         
(:


:)        

)
};
declare function local:persons($node, $id, $idShort, $typeShort){
(
(:Series statement:)
    for $series in $node/descendant::tei:seriesStmt
    return local:make-triple(local:make-uri($id), 'rdfs:partOf', local:make-uri($series/tei:idno/text())),
(: RDFs Label from headwords:)
    for $headword in $node/descendant::tei:person/tei:persName[@srophe:tags='#syriaca-headword'] | $node/descendant::tei:personGrp/tei:persName[@srophe:tags='#syriaca-headword']
    let $lang := $headword/@xml:lang
    return local:make-triple(local:make-uri($id), 'rdfs:label', local:make-literal($headword/descendant-or-self::text(),$lang,'')), 
(: hasCitation - bibl referenes :)
    for $citation in $node/descendant::tei:bibl/tei:ptr/@target[contains(., 'syriaca.org/')]
    return local:make-triple(local:make-uri($id), 'lawd:hasCitation', local:make-uri($citation)),
(:primaryTopicOf idno in publication statement :)
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.tei'))),
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.html'))),
    local:make-triple(local:make-uri($id), 'foaf:primaryTopicOf', local:make-uri(concat($id,'.ttl'))),
(: dcterms:hasFormat idno in publication statement :)
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.tei'))),
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.html'))),
    local:make-triple(local:make-uri($id), 'dcterms:hasFormat', local:make-uri(concat($id,'.ttl'))),
(: Description/abstract :)
    for $note in $node/descendant::tei:note[@type='abstract']
    return local:make-triple(local:make-uri($id), 'schema:description', local:make-literal($note/descendant-or-self::text(),$note/@xml:lang,'')),
    for $note in $node/descendant::tei:desc[@type='abstract']
     return local:make-triple(local:make-uri($id), 'schema:description', local:make-literal($note/descendant-or-self::text(),$note/@xml:lang,'')),
(:WS:NOTE literal does not work
    Description/abstract as an XML literal
    for $note in $node/descendant::tei:note[@type='abstract']
    return local:make-triple('', 'rdfs:XMLLiteral', concat('"',$note/self::*,'"')),
    :)
(: relations :)
    let $relPersons := distinct-values($node/descendant::tei:text/descendant::tei:persName/@ref)
    for $relPers in $relPersons[. != $id]
    return local:make-triple(local:make-uri($id), 'foaf:relation', local:make-uri($relPers)),
    let $relPlaces := distinct-values($node/descendant::tei:text/descendant::tei:placeName/@ref)
    for $relPlace in $relPlaces[. != $id]
    return local:make-triple(local:make-uri($id), 'foaf:relation', local:make-uri($relPlace)),
(: Name varients :)
    for $nameVariant in $node/descendant::tei:person/tei:persName | $node/descendant::tei:personGrp/tei:persName
    return local:make-triple(local:make-uri($id), 'swdt:name-variant', local:make-literal($nameVariant/descendant-or-self::text(),$nameVariant/@xml:lang,'')),
    
    (: Name variant unique statement instance :)
    for $nameVariant at $p in $node/descendant::tei:person/tei:persName | $node/descendant::tei:personGrp/tei:persName
    return 
        (local:make-triple(local:make-uri($id), 'sp:name-variant', concat('swds:',$typeShort,'-',$idShort,'-',$p)),
        local:make-triple(concat('swds:',$typeShort,'-',$idShort,'-',$p), 'sps:name-variant', local:make-literal($nameVariant/descendant-or-self::text(),$nameVariant/@xml:lang,'')),
        local:make-triple(concat('swds:',$typeShort,'-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(:IDNO :) 
    for $closeMatch at $p in $node/descendant::tei:text/descendant::tei:idno[@type ='URI'][not(contains(., "syriaca.org"))][not(contains(., "/viaf.org/viaf/"))]
    return 
        (local:make-triple(local:make-uri($id), 'swdt:closeMatch', local:make-uri($closeMatch)),
        local:make-triple(local:make-uri($id), 'sp:closeMatch', concat('swds:closeMatch-',$idShort, '-',$p)),
        local:make-triple(concat('swds:closeMatch-',$idShort, '-',$p), 'sps:closeMatch', local:make-uri($closeMatch)),
        local:make-triple(concat('swds:closeMatch-',$idShort, '-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: Floruit :)
    for $floruit at $p in $node/descendant::tei:text/descendant::tei:floruit/tei:date
    return 
        if($floruit/@when != '') then
            (
                local:make-triple(local:make-uri($id), 'swdt:floruit-when', local:make-date(string($floruit/@when))),
                local:make-triple(local:make-uri($id), 'sp:floruit-when', concat('swds:floruit-when','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-when','-',$idShort,'-',$p), 'sps:floruit-when', local:make-date(string($floruit/@when))),
                local:make-triple(concat('swds:floruit-when','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($floruit/@notBefore != '') then
            if($floruit/@notAfter) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:floruit-notBefore', local:make-date(string($floruit/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:floruit-notBefore', concat('swds:floruit-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-notBefore','-',$idShort,'-',$p), 'sps:floruit-notBefore', local:make-date(string($floruit/@notBefore))),
                local:make-triple(concat('swds:floruit-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:floruit-notAfter', local:make-date(string($floruit/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:floruit-notAfter', concat('swds:floruit-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-notAfter','-',$idShort,'-',$p), 'sps:floruit-notAfter', local:make-date(string($floruit/@notAfter))),
                local:make-triple(concat('swds:floruit-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:floruit-notBefore', local:make-date(string($floruit/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:floruit-notBefore', concat('swds:floruit-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-notBefore','-',$idShort,'-',$p), 'sps:floruit-notBefore', local:make-date(string($floruit/@notBefore))),
                local:make-triple(concat('swds:floruit-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($floruit/@notAfter) then
            (
                local:make-triple(local:make-uri($id), 'swdt:floruit-notAfter', local:make-date(string($floruit/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:floruit-notAfter', concat('swds:floruit-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-notAfter','-',$idShort,'-',$p), 'sps:floruit-notAfter', local:make-date(string($floruit/@notAfter))),
                local:make-triple(concat('swds:floruit-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($floruit/@from != '') then
            if($floruit/@to) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:floruit-from', local:make-date(string($floruit/@from))),
                local:make-triple(local:make-uri($id), 'sp:floruit-from', concat('swds:floruit-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-from','-',$idShort,'-',$p), 'sps:floruit-from', local:make-date(string($floruit/@from))),
                local:make-triple(concat('swds:floruit-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:floruit-to', local:make-date(string($floruit/@to))),
                local:make-triple(local:make-uri($id), 'sp:floruit-to', concat('swds:floruit-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-to','-',$idShort,'-',$p), 'sps:floruit-to', local:make-date(string($floruit/@to))),
                local:make-triple(concat('swds:floruit-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:floruit-from', local:make-date(string($floruit/@from))),
                local:make-triple(local:make-uri($id), 'sp:floruit-from', concat('swds:floruit-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-from','-',$idShort,'-',$p), 'sps:floruit-from', local:make-date(string($floruit/@from))),
                local:make-triple(concat('swds:floruit-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($floruit/@to) then
            (
                local:make-triple(local:make-uri($id), 'swdt:floruit-to', local:make-date(string($floruit/@to))),
                local:make-triple(local:make-uri($id), 'sp:floruit-to', concat('swds:floruit-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:floruit-to','-',$idShort,'-',$p), 'sps:floruit-to', local:make-date(string($floruit/@to))),
                local:make-triple(concat('swds:floruit-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )        
        else (),
(:Birth Dates:)
    for $birth at $p in $node/descendant::tei:text/descendant::tei:birth/tei:date
    return 
        if($birth/@when != '') then
            (
                local:make-triple(local:make-uri($id), 'swdt:birth-when', local:make-date(string($birth/@when))),
                local:make-triple(local:make-uri($id), 'sp:birth-when', concat('swds:birth-when','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-when','-',$idShort,'-',$p), 'sps:birth-when', local:make-date(string($birth/@when))),
                local:make-triple(concat('swds:birth-when','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($birth/@notBefore != '') then
            if($birth/@notAfter) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:birth-notBefore', local:make-date(string($birth/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:birth-notBefore', concat('swds:birth-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-notBefore','-',$idShort,'-',$p), 'sps:birth-notBefore', local:make-date(string($birth/@notBefore))),
                local:make-triple(concat('swds:birth-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:birth-notAfter', local:make-date(string($birth/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:birth-notAfter', concat('swds:birth-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-notAfter','-',$idShort,'-',$p), 'sps:birth-notAfter', local:make-date(string($birth/@notAfter))),
                local:make-triple(concat('swds:birth-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:birth-notBefore', local:make-date(string($birth/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:birth-notBefore', concat('swds:birth-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-notBefore','-',$idShort,'-',$p), 'sps:birth-notBefore', local:make-date(string($birth/@notBefore))),
                local:make-triple(concat('swds:birth-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($birth/@notAfter) then
            (
                local:make-triple(local:make-uri($id), 'swdt:birth-notAfter', local:make-date(string($birth/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:birth-notAfter', concat('swds:birth-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-notAfter','-',$idShort,'-',$p), 'sps:birth-notAfter', local:make-date(string($birth/@notAfter))),
                local:make-triple(concat('swds:birth-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($birth/@from != '') then
            if($birth/@to) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:birth-from', local:make-date(string($birth/@from))),
                local:make-triple(local:make-uri($id), 'sp:birth-from', concat('swds:birth-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-from','-',$idShort,'-',$p), 'sps:birth-from', local:make-date(string($birth/@from))),
                local:make-triple(concat('swds:birth-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:birth-to', local:make-date(string($birth/@to))),
                local:make-triple(local:make-uri($id), 'sp:birth-to', concat('swds:birth-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-to','-',$idShort,'-',$p), 'sps:birth-to', local:make-date(string($birth/@to))),
                local:make-triple(concat('swds:birth-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:birth-from', local:make-date(string($birth/@from))),
                local:make-triple(local:make-uri($id), 'sp:birth-from', concat('swds:birth-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-from','-',$idShort,'-',$p), 'sps:birth-from', local:make-date(string($birth/@from))),
                local:make-triple(concat('swds:birth-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($birth/@to) then
            (
                local:make-triple(local:make-uri($id), 'swdt:birth-to', local:make-date(string($birth/@to))),
                local:make-triple(local:make-uri($id), 'sp:birth-to', concat('swds:birth-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:birth-to','-',$idShort,'-',$p), 'sps:birth-to', local:make-date(string($birth/@to))),
                local:make-triple(concat('swds:birth-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )        
        else (),
(:Death Dates:)
    for $death at $p in $node/descendant::tei:text/descendant::tei:death/tei:date
    return 
        if($death/@when != '') then
            (
                local:make-triple(local:make-uri($id), 'swdt:death-when', local:make-date(string($death/@when))),
                local:make-triple(local:make-uri($id), 'sp:death-when', concat('swds:death-when','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-when','-',$idShort,'-',$p), 'sps:death-when', local:make-date(string($death/@when))),
                local:make-triple(concat('swds:death-when','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($death/@notBefore != '') then
            if($death/@notAfter) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:death-notBefore', local:make-date(string($death/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:death-notBefore', concat('swds:death-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-notBefore','-',$idShort,'-',$p), 'sps:death-notBefore', local:make-date(string($death/@notBefore))),
                local:make-triple(concat('swds:death-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:death-notAfter', local:make-date(string($death/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:death-notAfter', concat('swds:death-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-notAfter','-',$idShort,'-',$p), 'sps:death-notAfter', local:make-date(string($death/@notAfter))),
                local:make-triple(concat('swds:death-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:death-notBefore', local:make-date(string($death/@notBefore))),
                local:make-triple(local:make-uri($id), 'sp:death-notBefore', concat('swds:death-notBefore','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-notBefore','-',$idShort,'-',$p), 'sps:death-notBefore', local:make-date(string($death/@notBefore))),
                local:make-triple(concat('swds:death-notBefore','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($death/@notAfter) then
            (
                local:make-triple(local:make-uri($id), 'swdt:death-notAfter', local:make-date(string($death/@notAfter))),
                local:make-triple(local:make-uri($id), 'sp:death-notAfter', concat('swds:birth-notAfter','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-notAfter','-',$idShort,'-',$p), 'sps:birth-notAfter', local:make-date(string($death/@notAfter))),
                local:make-triple(concat('swds:death-notAfter','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
        else if($death/@from != '') then
            if($death/@to) then 
            (
                local:make-triple(local:make-uri($id), 'swdt:death-from', local:make-date(string($death/@from))),
                local:make-triple(local:make-uri($id), 'sp:death-from', concat('swds:death-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-from','-',$idShort,'-',$p), 'sps:death-from', local:make-date(string($death/@from))),
                local:make-triple(concat('swds:death-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
                local:make-triple(local:make-uri($id), 'swdt:death-to', local:make-date(string($death/@to))),
                local:make-triple(local:make-uri($id), 'sp:death-to', concat('swds:birth-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-to','-',$idShort,'-',$p), 'sps:death-to', local:make-date(string($death/@to))),
                local:make-triple(concat('swds:death-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )
            else 
                (
                local:make-triple(local:make-uri($id), 'swdt:death-from', local:make-date(string($death/@from))),
                local:make-triple(local:make-uri($id), 'sp:death-from', concat('swds:death-from','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-from','-',$idShort,'-',$p), 'sps:death-from', local:make-date(string($death/@from))),
                local:make-triple(concat('swds:death-from','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
                )
        else if($death/@to) then
            (
                local:make-triple(local:make-uri($id), 'swdt:death-to', local:make-date(string($death/@to))),
                local:make-triple(local:make-uri($id), 'sp:death-to', concat('swds:death-to','-',$idShort,'-',$p)),
                local:make-triple(concat('swds:death-to','-',$idShort,'-',$p), 'sps:death-to', local:make-date(string($death/@to))),
                local:make-triple(concat('swds:death-to','-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
            )        
        else (),
(: Birth Place:)
    for $birthPlace at $p in $node/descendant::tei:text/descendant::tei:birth[tei:placeName]/tei:placeName[@ref]
    let $ref := $birthPlace/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:birth-place', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:birth-place', concat('swds:birth-place-',$idShort,'-',$p)),
        local:make-triple(concat('swds:birth-place-',$idShort,'-',$p), 'sps:birth-place', local:make-uri($ref)),
        local:make-triple(concat('swds:birth-place-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: Death Place:)
    for $deathPlace at $p in $node/descendant::tei:text/descendant::tei:death[tei:placeName]/tei:placeName[@ref]
    let $ref := $deathPlace/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:death-place', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:death-place', concat('swds:death-place-',$idShort,'-',$p)),
        local:make-triple(concat('swds:death-place-',$idShort,'-',$p), 'sps:death-place', local:make-uri($ref)),
        local:make-triple(concat('swds:death-place-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: Gender Place:)
    for $gender at $p in $node/descendant::tei:text/descendant::tei:gender[@ana]
    for $ana in tokenize($gender/@ana,' ')
    let $ref := $ana
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:gender', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:gender', concat('swds:gender-',$idShort,'-',$p)),
        local:make-triple(concat('swds:gender-',$idShort,'-',$p), 'sps:gender', local:make-uri($ref)),
        local:make-triple(concat('swds:gender-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ),
(: WS:Note, may be an issue with the first triple because these are uris may need some help here 
    Occupation :)    
    for $occupation at $p in $node/descendant::tei:text/descendant::tei:state[@type='occupation'][@ref != '']
    let $ref := $occupation/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:occupation', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:occupation', concat('swds:occupation-',$idShort,'-',$p)),
        local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'sps:occupation', local:make-uri($ref)),
        local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
        if($occupation/@when) then
            local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spq:when', local:make-date(string($occupation/@when)))
        else if($occupation/@notBefore) then 
            local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spq:not-before', local:make-date(string($occupation/@notBefore)))
        else if($occupation/@notAfter) then 
            local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spq:not-after', local:make-date(string($occupation/@notAfter)))
        else if($occupation/@from) then 
            local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spq:from', local:make-date(string($occupation/@from)))
        else if($occupation/@to) then 
            local:make-triple(concat('swds:occupation-',$idShort,'-',$p), 'spq:not-to', local:make-date(string($occupation/@to)))
        else ()
        ), 
(: WS:Note, may be an issue with the first triple because these are uris may need some help here 
    Socio Economic Status :)    
    for $economic at $p in $node/descendant::tei:text/descendant::tei:state[@type='socio-economic-status'][@ref != '']
    let $ref := $economic/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:socio-economic-status', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:socio-economic-status', concat('swds:socio-economic-status-',$idShort,'-',$p)),
        local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'sps:socio-economic-status', local:make-uri($ref)),
        local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
        if($economic/@when) then
            local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spq:when', local:make-date(string($economic/@when)))
        else if($economic/@notBefore) then 
            local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spq:not-before', local:make-date(string($economic/@notBefore)))
        else if($economic/@notAfter) then 
            local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spq:not-after', local:make-date(string($economic/@notAfter)))
        else if($economic/@from) then 
            local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spq:from', local:make-date(string($economic/@from)))
        else if($economic/@to) then 
            local:make-triple(concat('swds:socio-economic-status-',$idShort,'-',$p), 'spq:not-to', local:make-date(string($economic/@to)))
        else ()
        ),
(: WS:Note, may be an issue with the first triple because these are uris may need some help here 
    Status :)    
    for $status at $p in $node/descendant::tei:text/descendant::tei:state[@type='status'][@ref != '']
    let $ref := $status/@ref
    return 
        (
        local:make-triple(local:make-uri($id), 'swdt:status', local:make-uri($ref)),
        local:make-triple(local:make-uri($id), 'sp:status', concat('swds:status-',$idShort,'-',$p)),
        local:make-triple(concat('swds:status-',$idShort,'-',$p), 'sps:status', local:make-uri($ref)),
        local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
        if($status/@when) then
            local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spq:when', local:make-date(string($status/@when)))
        else if($status/@notBefore) then 
            local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spq:not-before', local:make-date(string($status/@notBefore)))
        else if($status/@notAfter) then 
            local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spq:not-after', local:make-date(string($status/@notAfter)))
        else if($status/@from) then 
            local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spq:from', local:make-date(string($status/@from)))
        else if($status/@to) then 
            local:make-triple(concat('swds:status-',$idShort,'-',$p), 'spq:not-to', local:make-date(string($status/@to)))
        else ()
        ),
(: WS:Note, may be an issue with the first triple because these are uris may need some help here 
    commemorates :)    
    for $commemorates at $p in $node/descendant::tei:text/descendant::tei:event[@type='veneration'][descendant::tei:rs[@ref != '']]
    let $ref := $commemorates/descendant::tei:rs/@ref
    return 
        (
        local:make-triple(local:make-uri($ref), 'swdt:commemorates' ,local:make-uri($id)),
        local:make-triple(local:make-uri($ref), 'sp:commemorates' ,concat('swds:commemorates-',$idShort,'-',$p)),
        local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'sps:commemorates' ,local:make-uri($id)),
        local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spr:reference-URL', local:make-uri(concat($id,'.tei'))),
        if($commemorates/@when) then
            local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spq:when', local:make-date(string($commemorates/@when)))
        else if($commemorates/@notBefore) then 
            local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spq:not-before', local:make-date(string($commemorates/@notBefore)))
        else if($commemorates/@notAfter) then 
            local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spq:not-after', local:make-date(string($commemorates/@notAfter)))
        else if($commemorates/@from) then 
            local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spq:from', local:make-date(string($commemorates/@from)))
        else if($commemorates/@to) then 
            local:make-triple(concat('swds:commemorates-',$idShort,'-',$p), 'spq:not-to', local:make-date(string($commemorates/@to)))
        else ()
        ),
(: Relationships :)
     for $relation at $p in $node/descendant::tei:text/descendant::tei:relation
     let $relRef := substring-after($relation/@ref,'taxonomy/')
     return (
        for $s at $ap in tokenize($relation/@active,' ')
        let $sRef := $s
        return
           for $o at $op in tokenize($relation/@passive,' ')
           let $oRef := $o
           return
               (
               local:make-triple(local:make-uri($sRef), concat('swdt:',$relRef), local:make-uri($oRef)),
               local:make-triple(local:make-uri($sRef), concat('sp:',$relRef), concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap), concat('swd:',$relRef), local:make-uri($oRef)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$ap), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
               ), 
          for $s at $m1p in tokenize($relation/@mutual,' ')
          let $sRef := $s
          return   
            for $o at $m2p in tokenize($relation/@mutual,' ')[. != $s]
            let $oRef := $o
            return 
               (
               local:make-triple(local:make-uri($sRef), concat('swdt:',$relRef), local:make-uri($oRef)),
               local:make-triple(local:make-uri($sRef), concat('sp:',$relRef), concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p), concat('swd:',$relRef), local:make-uri($oRef)),
               local:make-triple(concat('swds:activeRelation',$relRef,'-',$idShort,'-',$p,$m1p), 'spr:reference-URL', local:make-uri(concat($id,'.tei')))
        ))          
)


};

(: Prefixes :)
declare function local:prefix() as xs:string{
"@prefix swd: <http://syriaca.org/> .
@prefix swds: <http://syriaca-person/entity/statement/> .
@prefix swdt: <http://syriaca.org/prop/direct/> .
@prefix sp: <http://syriaca.org/prop/> .
@prefix sps: <http://syriaca.org/prop/statement/> .
@prefix spr: <http://syriaca.org/prop/reference/> .
@prefix spq: <http://syriaca.org/prop/qualifier/> .
@prefix swdref: <http://spear-prosop/reference/> .
@prefix schema: <http://schema.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix cwrc: <http://sparql.cwrc.ca/ontologies/cwrc#>.
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix foaf:	<http://xmlns.com/foaf/0.1/> .
@prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .
@prefix geosparql: <http://www.opengis.net/ont/geosparql#> .
@prefix lawd:	<http://lawd.info/ontology/> .
@prefix owl:	<http://www.w3.org/2002/07/owl#> .
@prefix periodo:	<http://n2t.net/ark:/99152/p0v#> .
@prefix person:	<https://www.w3.org/ns/person> .
@prefix skos:	<http://www.w3.org/2004/02/skos/core#> .
@prefix syriaca:	<http://syriaca.org/schema#> .
@prefix snap:	<http://data.snapdrgn.net/ontology/snap#> . 
@prefix time:	<http://www.w3.org/2006/time#> .
@prefix wdata:	<https://www.wikidata.org/wiki/Special:EntityData/> .
@prefix xsd:	<http://www.w3.org/2001/XMLSchema#> .&#xa;"
};

(local:prefix(),local:make-triple-set(.))