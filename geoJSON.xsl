<xsl:stylesheet  
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:x="http://www.w3.org/1999/xhtml" 
    xmlns:srophe="https://srophe.app" 
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:local="http://syriaca.org/ns" 
    exclude-result-prefixes="xs t x saxon local" version="3.0">
    
    <xsl:output method="text" encoding="utf-8"/>
    
    <!-- Run on the directory with places in related elements must have type relatedPlace  ex:  /Users/wsalesky/syriaca/syriaca/syriaca-data/data/persons/tei-->
    <xsl:param name="relatedCollectionPath" select="''"/>
    <!-- Directory places TEI -->
    <xsl:param name="placesCollectionPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca-data/data/places/tei'"/>
    <!-- Sub collection of places, currently only used for  Gazetteer to John of Ephesus’s Ecclesiastical History-->
    <xsl:param name="subCollection" select="''"/>
    
    <!-- places for runinng on placesCollectionPath for placesTEI or relatedPlace for finding realted places  relatedPlace -->
    <xsl:param name="mapType" select="''"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$mapType = 'relatedPlace'">
                <xsl:result-document href="relatedPlaces.json">
                    <xsl:variable name="xml">
                        <map xmlns="http://www.w3.org/2005/xpath-functions">
                            <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">FeatureCollection</string>  
                            <xsl:call-template name="listPlaces"/>
                        </map>
                    </xsl:variable>
                    <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
                </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="places.json">
                    <xsl:variable name="xml">
                        <map xmlns="http://www.w3.org/2005/xpath-functions">
                            <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">FeatureCollection</string>  
                            <array key="features" xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:for-each select="collection(xs:anyURI(concat($placesCollectionPath, '?select=*.xml')))" >
                                    <xsl:choose>
                                        <xsl:when test="$subCollection != ''">
                                            <xsl:if test=".[descendant::tei:seriesStmt/tei:title[. = $subCollection]]">
                                                <xsl:call-template name="geoJson"/>            
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="geoJson"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </array>
                        </map>
                    </xsl:variable>
                    <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="relatedPlacesList">
        <relatedPlaces>
            <xsl:for-each select="collection(xs:anyURI(concat($relatedCollectionPath, '?select=*.xml')))" >
                <xsl:if test="descendant::tei:relation[contains(@passive,'/place/') or contains(@active,'/place/') or contains(@mutual,'/place/')]">
                    <xsl:variable name="id">
                        <xsl:choose>
                            <xsl:when test="descendant::tei:publicationStmt/tei:idno[@type='URI']">
                                <xsl:value-of select="replace(descendant::tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="descendant::tei:idno[1]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="title">
                        <xsl:choose>
                            <xsl:when test="descendant::*[@srophe:tags='#headword']">
                                <xsl:value-of select="descendant::*[@srophe:tags='#headword'][1]"/>
                            </xsl:when>
                            <xsl:when test="descendant::*[@syriaca-tags='#syriaca-headword']">
                                <xsl:value-of select="descendant::*[@syriaca-tags='#syriaca-headword'][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="descendant::tei:title[1]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <record xmlns="http://www.tei-c.org/ns/1.0">
                        <title xmlns="http://www.tei-c.org/ns/1.0" id="{$id}"><xsl:value-of select="string($title)"/></title>
                        <xsl:variable name="related" select="descendant::tei:relation/@passive | descendant::tei:relation/@active | descendant::tei:relation/@mutual"></xsl:variable>
                        <xsl:for-each select="tokenize(string-join($related,' '),' ')[contains(.,'/place/')]">
                            <placeName xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></placeName>
                        </xsl:for-each>
                    </record>
                </xsl:if>
            </xsl:for-each>
        </relatedPlaces>
    </xsl:template>
    <xsl:template name="listPlaces">
        <xsl:variable name="relatedPlacesList">
            <xsl:call-template name="relatedPlacesList"/>
        </xsl:variable>
        <array key="features" xmlns="http://www.w3.org/2005/xpath-functions">
            <xsl:for-each select="collection(xs:anyURI(concat($placesCollectionPath, '?select=*.xml')))">
                <xsl:variable name="id">
                    <xsl:choose>
                        <xsl:when test="descendant::tei:publicationStmt/tei:idno[@type='URI']">
                            <xsl:value-of select="replace(descendant::tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="descendant::tei:idno[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$relatedPlacesList/descendant-or-self::*:placeName = $id">
                    <xsl:variable name="title">
                        <xsl:choose>
                            <xsl:when test="descendant::*[@srophe:tags='#headword']">
                                <xsl:value-of select="descendant::*[@srophe:tags='#headword'][1]"/>
                            </xsl:when>
                            <xsl:when test="descendant::*[@syriaca-tags='#syriaca-headword']">
                                <xsl:value-of select="descendant::*[@syriaca-tags='#syriaca-headword'][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="descendant::tei:title[1]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="type">
                        <xsl:choose>
                            <xsl:when test="descendant::tei:relationType != ''">
                                <xsl:value-of select="descendant::tei:relationType != ''"/>
                            </xsl:when>
                            <xsl:when test="descendant::tei:place/@type">
                                <xsl:value-of select="descendant::tei:place/@type"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="coords">
                        <xsl:choose>
                            <xsl:when test="descendant::tei:location[@subtype = 'preferred']">
                                <xsl:value-of select="descendant::tei:location[@subtype = 'preferred']/tei:geo"/>
                            </xsl:when>
                            <xsl:when test="descendant::tei:geo">
                                <xsl:value-of select="descendant::tei:geo[1]"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="$coords != ''">
                        <map xmlns="http://www.w3.org/2005/xpath-functions">
                            <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">Feature</string>
                            <map xmlns="http://www.w3.org/2005/xpath-functions" key="geometry">
                                <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">Point</string>
                                <array key="coordinates" xmlns="http://www.w3.org/2005/xpath-functions">
                                    <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[2]"/></number>
                                    <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[1]"/></number>
                                </array>
                            </map>
                            <map xmlns="http://www.w3.org/2005/xpath-functions" key="properties">
                                <string key="uri" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$id"/></string>
                                <string key="name" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join($title,' '))"/></string>
                                <array xmlns="http://www.w3.org/2005/xpath-functions" key="relatedRecords"> 
                                    <xsl:for-each select="$relatedPlacesList/descendant-or-self::*:placeName[. = $id]/parent::*:record">
                                        <map xmlns="http://www.w3.org/2005/xpath-functions">  
                                            <string key="id" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="string(*:title/@id)"/></string>
                                            <string key="title" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="*:title"/></string>
                                        </map>
                                    </xsl:for-each>
                                </array>
                                <xsl:if test="$type != ''">
                                    <string key="type" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join($type,' '))"/></string>    
                                </xsl:if>
                            </map>
                        </map> 
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </array>
    </xsl:template>
    <xsl:template name="geoJson">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="descendant::tei:publicationStmt/tei:idno[@type='URI']">
                    <xsl:value-of select="replace(descendant::tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="descendant::tei:idno[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="descendant::*[@srophe:tags='#headword']">
                    <xsl:value-of select="descendant::*[@srophe:tags='#headword'][1]"/>
                </xsl:when>
                <xsl:when test="descendant::*[@syriaca-tags='#syriaca-headword']">
                    <xsl:value-of select="descendant::*[@syriaca-tags='#syriaca-headword'][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="descendant::tei:title[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="desc">
                <xsl:if test="descendant::tei:desc">
                    <xsl:value-of select="normalize-space(string-join(descendant::tei:desc,' '))"/>
                </xsl:if>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="descendant::tei:relationType != ''">
                    <xsl:value-of select="descendant::tei:relationType != ''"/>
                </xsl:when>
                <xsl:when test="descendant::tei:place/@type">
                    <xsl:value-of select="descendant::tei:place/@type"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="coords">
            <xsl:choose>
                <xsl:when test="descendant::tei:location[@subtype = 'preferred']">
                    <xsl:value-of select="descendant::tei:location[@subtype = 'preferred']/tei:geo"/>
                </xsl:when>
                <xsl:when test="descendant::tei:geo">
                    <xsl:value-of select="descendant::tei:geo[1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$coords != ''">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">Feature</string>
                <map xmlns="http://www.w3.org/2005/xpath-functions" key="geometry">
                    <string key="type" xmlns="http://www.w3.org/2005/xpath-functions">Point</string>
                    <array key="coordinates" xmlns="http://www.w3.org/2005/xpath-functions">
                        <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[2]"/></number>
                        <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[1]"/></number>
                    </array>
                </map>
                <map xmlns="http://www.w3.org/2005/xpath-functions" key="properties">
                    <string key="uri" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$id"/></string>
                    <string key="name" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join($title,' '))"/></string>
                    <xsl:if test="$desc != ''">
                        <string key="desc" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join($desc,' '))"/></string>    
                    </xsl:if>
                    <xsl:if test="$type != ''">
                        <string key="type" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join($type,' '))"/></string>    
                    </xsl:if>
                </map>
            </map> 
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>