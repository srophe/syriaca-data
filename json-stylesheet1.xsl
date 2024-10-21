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

    <!-- Parameters and variables -->
    <xsl:param name="configPath" select="'./repo-config.xml'"/>
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>

    <!-- Custom functions -->
    <!-- Function to normalize English strings for sorting -->
    <xsl:function name="local:sortStringEn">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(normalize-space($string),'^\s+|^[‘|ʻ|ʿ|ʾ]|^[tT]he\s+[^\p{L}]+|^[dD]e\s+|^[dD]e-|^[oO]n\s+[aA]\s+|^[oO]n\s+|^[aA]l-|^[aA]n\s|^[aA]\s+|^\d*\W|^[^\p{L}]','')"/>
    </xsl:function>

    <!-- Function to normalize Arabic strings for sorting -->
    <xsl:function name="local:sortStringAr">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(
            replace(
            replace(
            replace(
            replace($string[1],'^\s+',''), 
            '[ً-ٖ]',''), 
            '(^|\s)(ال|أل|ٱل)',''), 
            'آ|إ|أ|ٱ','ا'), 
            '^(ابن|إبن|بن)','')"/>
    </xsl:function>

    <!-- Function to build date strings -->
    <xsl:function name="local:buildDate">
        <xsl:param name="element" as="node()"/>
        <xsl:if test="$element/@when or $element/@notBefore or $element/@notAfter or $element/@from or $element/@to">
            <xsl:choose>
                <!-- Formats 'from' and 'to' dates -->
                <xsl:when test="$element/@from">
                    <xsl:choose>
                        <xsl:when test="$element/@to">
                            <xsl:value-of select="local:trim-date($element/@from)"/>-<xsl:value-of select="local:trim-date($element/@to)"/>
                        </xsl:when>
                        <xsl:otherwise>from <xsl:value-of select="local:trim-date($element/@from)"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- 'to' date only -->
                <xsl:when test="$element/@to">to <xsl:value-of select="local:trim-date($element/@to)"/></xsl:when>
            </xsl:choose>
            <!-- Handle 'notBefore' and 'notAfter' -->
            <xsl:if test="$element/@notBefore">
                <xsl:text>, not before </xsl:text><xsl:value-of select="local:trim-date($element/@notBefore)"/>
            </xsl:if>
            <xsl:if test="$element/@notAfter">
                <xsl:text>, not after </xsl:text><xsl:value-of select="local:trim-date($element/@notAfter)"/>
            </xsl:if>
            <!-- Formats the 'when' attribute -->
            <xsl:if test="$element/@when">
                <xsl:text>, </xsl:text><xsl:value-of select="local:trim-date($element/@when)"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>

    <!-- Function to trim leading zeros from dates -->
    <xsl:function name="local:trim-date">
        <xsl:param name="date"/>
        <xsl:choose>
            <!-- Remove leading zero for BCE dates -->
            <xsl:when test="starts-with($date,'-0')">
                <xsl:value-of select="concat(substring($date,3),' BCE')"/>
            </xsl:when>
            <!-- Remove leading zero for CE dates -->
            <xsl:when test="starts-with($date,'0')">
                <xsl:value-of select="local:trim-date(substring($date,2))"/>
            </xsl:when>
            <!-- Default case: no change -->
            <xsl:otherwise>
                <xsl:value-of select="$date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Root template: builds the JSON output -->
    <xsl:template match="/">
        <xsl:variable name="doc">
            <xsl:sequence select="."/>
        </xsl:variable>
        <!-- Create a map for JSON conversion -->
        <xsl:variable name="json">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <!-- Iterate over fields defined in the config -->
                <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                    <xsl:choose>
                        <!-- If the field has a function, apply the corresponding template -->
                        <xsl:when test="@function != ''">
                            <xsl:variable name="function" select="@function"/>
                            <xsl:apply-templates select="." mode="fields">
                                <xsl:with-param name="doc" select="$doc"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <!-- If the field has an XPath expression -->
                        <xsl:when test="@xpath != ''">
                            <!-- Implement XPath handling if needed -->
                            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">XPath function not implemented</string>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>Incorrect field formatting</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </map>
        </xsl:variable>
        <!-- Output the JSON -->
        <xsl:value-of select="xml-to-json($json, map { 'indent' : true() })"/>
    </xsl:template>

    <!-- Template to handle fields with a specific function -->
    <xsl:template match="*:fields" mode="fields">
        <xsl:param name="doc"/>
        <xsl:variable name="function" select="@function"/>
        <!-- Call the template matching the function -->
        <xsl:apply-templates select="." mode="{$function}">
            <xsl:with-param name="doc" select="$doc"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Template for 'fullText' function -->
    <xsl:template match="*:fields" mode="fullText">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
            <!-- Extract text from tei:body -->
            <xsl:variable name="bodyText">
                <!-- Use the tei namespace for correct matching -->
                <xsl:apply-templates select="$doc/tei:TEI/tei:text/tei:body/descendant::text()" mode="fullText"/>
            </xsl:variable>
            <xsl:value-of select="$bodyText"/>
        </xsl:variable>
        <!-- Add the 'fullText' field to the JSON if it's not empty -->
        <xsl:if test="normalize-space($field) != ''">
            <string key="{@name}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>

    <!-- Mode for processing fullText content -->
    <xsl:template match="text()" mode="fullText">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Template for 'title' function -->
    <xsl:template match="*:fields" mode="title">
        <xsl:param name="doc"/>
        <!-- Your existing logic for extracting 'title' goes here -->
        <!-- ... (use your existing code for the 'title' function) -->
        <!-- Example: -->
        <xsl:variable name="field">
            <!-- Implement your logic to extract the title -->
            <xsl:value-of select="local:sortStringEn($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>
        </xsl:variable>
        <!-- Add the 'title' field to the JSON if it's not empty -->
        <xsl:if test="$field != ''">
            <string key="{@name}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>

    <!-- Similar templates for other functions like 'idno', 'series', etc. -->
    <!-- Example for 'idno' function -->
    <xsl:template match="*:fields" mode="idno">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
            <xsl:value-of select="replace($doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
        </xsl:variable>
        <!-- Add the 'idno' field to the JSON if it's not empty -->
        <xsl:if test="$field != ''">
            <string key="{@name}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>

    <!-- ... (Add templates for other functions as needed) -->

    <!-- Empty template to suppress unwanted 'fields' elements -->
    <xsl:template match="*:fields"/>

</xsl:stylesheet>
