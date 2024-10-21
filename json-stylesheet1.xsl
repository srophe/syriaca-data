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
    
    <!-- Output JSON text -->
    <xsl:output method="text" encoding="utf-8"/>

    <!-- Load configuration -->
    <xsl:param name="configPath" select="'./repo-config.xml'"/>
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>

    <!-- Helper function for sorting strings (English) -->
    <xsl:function name="local:sortStringEn">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(normalize-space($string),'^\s+|^[‘|ʻ|ʿ|ʾ]|^[tT]he\s+[^\p{L}]+|^[dD]e\s+|^[dD]e-|^[oO]n\s+[aA]\s+|^[oO]n\s+|^[aA]l-|^[aA]n\s|^[aA]\s+|^\d*\W|^[^\p{L}]','')"/>
    </xsl:function>

    <!-- Root template that builds the JSON -->
    <xsl:template match="/">
        <xsl:variable name="doc">
            <xsl:sequence select="."/>
        </xsl:variable>
        
        <!-- Create a map structure for the entire JSON -->
        <xsl:variable name="json">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                
                <!-- Extract fields from configuration -->
                <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                    <xsl:choose>
                        <xsl:when test="@function != ''">
                            <xsl:apply-templates select="."/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                
                <!-- Add fullText field using a separate mode -->
                <xsl:variable name="fullTextContent">
                    <xsl:apply-templates select="tei:TEI/tei:text/tei:body/descendant::text()" mode="fullText"/>
                </xsl:variable>
                <xsl:if test="normalize-space($fullTextContent) != ''">
                    <string key="fullText">
                        <xsl:value-of select="$fullTextContent"/>
                    </string>
                </xsl:if>
            </map>
        </xsl:variable>
        
        <!-- Output the final JSON -->
        <xsl:value-of select="xml-to-json($json, map { 'indent' : true() })"/>
    </xsl:template>

    <!-- Extract the fullText using a mode to avoid conflicts -->
    <xsl:template match="tei:TEI/tei:text/tei:body/descendant::text()" mode="fullText">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Template for handling specific fields (example for 'fullText') -->
    <xsl:template match="*:fields[@function = 'fullText']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
            <xsl:apply-templates select="$doc/descendant::text()"/>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>

    <!-- Add other field templates as needed, for example: -->
    <xsl:template match="*:fields[@function = 'title']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
            <xsl:value-of select="$doc/ancestor-or-self::tei:TEI/descendant::tei:titleStmt/tei:title[1]"/>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    
    <!-- Add other templates for series, idno, etc., as needed -->

</xsl:stylesheet>
