<xsl:stylesheet  
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:x="http://www.w3.org/1999/xhtml" 
    xmlns:srophe="https://srophe.app" 
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:local="http://syriaca.org/ns" 
    exclude-result-prefixes="xs t x saxon local" version="3.0">
    
<!-- XSLT to generate leaflet maps -->
    <xsl:template name="internalRelationships">
        <xsl:param name="root"/>
        
        <xsl:for-each-group select="$root/t:listRelation[not(parent::t:bibl/parent::t:bibl)]/t:relation" group-by="@ref">
            <div class="relation internal-relationships"  xmlns="http://www.w3.org/1999/xhtml">
                <xsl:variable name="ids" select="@active|@passive|@mutual"/>
                <xsl:variable name="related" select="string-join(distinct-values(tokenize($ids,' ')[not(. = $resource-id)]),' ')"/>
                <xsl:variable name="$relationshipTypeID" select="replace(current-grouping-key,' ','')"/>
                <h4 class="relationship-type"><xsl:value-of select="$resource-title"/>&#160;<xsl:value-of select="current-grouping-key()"/><xsl:value-of select="count($related)"/>
                    <div class="indent">
                        <xsl:for-each select="$related">
                            <!-- NEED to wait for RDF for this I think 
                                concat($dataPath,'/bibl/tei/',substring-after(t:ptr/@target, concat($base-uri,'/bibl/')),'.xml') -->
                            <xsl:variable name="relatedDocURL" select="concat($dataPath)"/>
                            <xsl:if test="doc-available($relatedDocURL)"></xsl:if>
                        </xsl:for-each>        
                    </div>
                </h4>
            </div>
        </xsl:for-each-group>
        <!-- 
        for $related in $relationships
    let $rel-id := index-of($record, $related[1])
    let $rel-type := if($related/@name) then $related/@name else if($related/@ref) then $related/@ref else $related/@name
    group by $relationship := $rel-type
    return 
        let $ids := string-join(($related/@active/string(),$related/@passive/string(),$related/@mutual/string()),' ')
        let $ids := 
            string-join(
                distinct-values(
                    tokenize($ids,' ')[not(. = $currentID)]),' ')
        let $count := count(tokenize($ids,' ')[not(. = $currentID)])
        let $relationship-type := $relationship 
        let $relationshipTypeID := replace($relationship-type,' ','')
        return 
            <div class="relation internal-relationships"  xmlns="http://www.w3.org/1999/xhtml">
                <h4 class="relationship-type">{$title[1]}&#160;{relations:stringify-relationship-type($relationship)} ({$count})</h4>
                <div class="indent">
                    <div class="dynamicContent" data-url="{concat($config:nav-base,'/modules/data.xql?ids=',$ids,'&amp;relID=',$relationshipTypeID,'&amp;relationship=internal')}"></div>
                    {
                    if($count gt 10) then 
                        <a class="more" href="{concat($config:nav-base,'/search.html?=?ids=',$ids,'&amp;relID=',$relationshipTypeID,'&amp;relationship=internal')}">See all</a>
                    else ()
                    }
                </div>
            </div>
        -->
        
    </xsl:template>
    <!-- WS: todo maybe
    declare function relations:stringify-relationship-type($type as xs:string*){
    if(global:odd2text('relation',$type) != '') then global:odd2text('relation',$type)    
    else relations:decode-relationship($type)
};

    -->
</xsl:stylesheet>