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
    
    <xsl:output method="text" encoding="utf-8"/>
    
    <xsl:param name="applicationPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca'"/>
    <xsl:param name="staticSitePath" select="'/Users/wsalesky/syriaca/syriaca/syriacaStatic'"/>
    <xsl:param name="dataPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca-data-test/data/'"/>
    <xsl:param name="configPath" select="concat($staticSitePath, '/siteGenerator/components/repo-config.xml')"/>
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>
    
    <!-- 
        Generate Index for OpenSearch
        Use repo-config to establish fields and field types
        Run once to establish the index. 
        Run Doc index to generate indvidual index documents
        
        <fields xpath="tei:TEI">fullText</fields>
            <fields function="title" boost="10">title</fields>
            <fields function="idno">idno</fields>
            <fields function="titleSyriac">titleSyriac</fields>
            <fields function="titleArabic">titleArabic</fields>
            <fields function="titleFrench">titleFrench</fields>
            <fields function="titleTransliteration">titleTransliteration</fields>
            <fields function="author" boost="8">author</fields>
            <fields xpath="tei:TEI/descendant::tei:sourceDesc/tei:bibl/tei:date/@when">publicationDate</fields>
            <fields function="cbssPublicationDate">cbssPublicationDate</fields>
            <fields function="cbssPubPlace">cbssPubPlace</fields>
            <fields function="cbssPubPlace">cbssLangFilter</fields>
            <text xpath="tei:TEI/descendant::tei:persName" boost="5.0">persName</text>
            <text xpath="tei:TEI/descendant::tei:placeName" boost="5.0">placeName</text>
            <text xpath="tei:TEI/descendant::tei:pubPlace">publPlace</text>
            <text xpath="tei:TEI/descendant::tei:publisher">publisher</text>
            
    -->
    <xsl:template match="/">
        <xsl:variable name="path">
            <xsl:value-of select="concat($staticSitePath,'/json/createIndex/newIndex.json')"/>
        </xsl:variable>
        <xsl:result-document href="{$path}">
            <xsl:call-template name="createIndex"/>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="createIndex">
        <xsl:variable name="xml">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <map key="mappings">
                    <map key="properties">
                        <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                            <xsl:choose>
                                <xsl:when test="@type ='date'">
                                    <map key="{.}Start">
                                        <string key="type">
                                            <xsl:choose>
                                                <xsl:when test="@type"><xsl:value-of select="string(@type)"/></xsl:when>
                                                <xsl:otherwise>text</xsl:otherwise>
                                            </xsl:choose>
                                        </string>
                                    </map>
                                    <map key="{.}End">
                                        <string key="type">
                                            <xsl:choose>
                                                <xsl:when test="@type"><xsl:value-of select="string(@type)"/></xsl:when>
                                                <xsl:otherwise>text</xsl:otherwise>
                                            </xsl:choose>
                                        </string>
                                    </map> 
                                </xsl:when>
                                <xsl:otherwise>
                                    <map key="{.}">
                                        <string key="type">
                                            <xsl:choose>
                                                <xsl:when test="@type"><xsl:value-of select="string(@type)"/></xsl:when>
                                                <xsl:otherwise>text</xsl:otherwise>
                                            </xsl:choose>
                                        </string>
                                    </map> 
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </map>
                </map>
            </map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
        <!--        <xsl:copy-of select="$xml"/>-->
    </xsl:template>
    
</xsl:stylesheet>