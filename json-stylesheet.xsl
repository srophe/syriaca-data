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
    
    <xsl:param name="configPath" select="'./repo-config.xml'"/>
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>
    
    <xsl:function name="local:sortStringEn">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(normalize-space($string),'^\s+|^[‘|ʻ|ʿ|ʾ]|^[tT]he\s+[^\p{L}]+|^[dD]e\s+|^[dD]e-|^[oO]n\s+[aA]\s+|^[oO]n\s+|^[aA]l-|^[aA]n\s|^[aA]\s+|^\d*\W|^[^\p{L}]','')"/>
    </xsl:function>
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
    <xsl:function name="local:buildDate">
        <xsl:param name="element" as="node()"/>
        <xsl:if test="$element/@when or $element/@notBefore or $element/@notAfter or $element/@from or $element/@to">
            <xsl:choose>
                <!-- Formats to and from dates -->
                <xsl:when test="$element/@from">
                    <xsl:choose>
                        <xsl:when test="$element/@to">
                            <xsl:value-of select="local:trim-date($element/@from)"/>-<xsl:value-of select="local:trim-date($element/@to)"/>
                        </xsl:when>
                        <xsl:otherwise>from <xsl:value-of select="local:trim-date($element/@from)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$element/@to">to <xsl:value-of select="local:trim-date($element/@to)"/>
                </xsl:when>
            </xsl:choose>
            <!-- Formats notBefore and notAfter dates -->
            <xsl:if test="$element/@notBefore">
                <!-- Adds comma if there are other dates -->
                <xsl:if test="$element/@to or $element/@from">, </xsl:if>not before <xsl:value-of select="local:trim-date($element/@notBefore)"/>
            </xsl:if>
            <xsl:if test="$element/@notAfter">
                <!-- Adds comma if there are other dates -->
                <xsl:if test="$element/@to or $element/@from or $element/@notBefore">, </xsl:if>not after <xsl:value-of select="local:trim-date($element/@notAfter)"/>
            </xsl:if>
            <!-- Formats when, single date -->
            <xsl:if test="$element/@when">
                <!-- Adds comma if there are other dates -->
                <xsl:if test="$element/@to or $element/@from or $element/@notBefore or $element/@notAfter">, </xsl:if>
                <xsl:value-of select="local:trim-date($element/@when)"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <!-- Date function to remove leading 0s -->
    <xsl:function name="local:trim-date">
        <xsl:param name="date"/>
        <xsl:choose>
            <!-- NOTE: This can easily be changed to display BCE instead -->
            <!-- removes leading 0 but leaves -  -->
            <xsl:when test="starts-with($date,'-0')">
                <xsl:value-of select="concat(substring($date,3),' BCE')"/>
            </xsl:when>
            <!-- removes leading 0 -->
            <xsl:when test="starts-with($date,'0')">
                <xsl:value-of select="local:trim-date(substring($date,2))"/>
            </xsl:when>
            <!-- passes value through without changing it -->
            <xsl:otherwise>
                <xsl:value-of select="$date"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--  <xsl:value-of select="string(number($date))"/>-->
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:variable name="doc">
            <xsl:sequence select="."/>
        </xsl:variable>
        <xsl:variable name="xml">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                    <xsl:choose>
                        <xsl:when test="@function != ''">
                            <xsl:variable name="function" select="@function"/>
                                <xsl:apply-templates select=".[@function = $function]">
                                    <xsl:with-param select="$doc" name="doc"/>
                                </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="@xpath != ''">
                            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">Test xpath function</string> 
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>Incorrect field formatting</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
    </xsl:template>
    
    <!-- Named functions, should match search fields in repo-config.xml -->
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
    <xsl:template match="*:fields[@function = 'title']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
         <xsl:choose>
             <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                 <xsl:variable name="en" select="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]"/>
                 <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                 <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
             </xsl:when>
             <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                 <xsl:variable name="en" select="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]"/>
                 <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                 <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
             </xsl:when>
             <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                 <xsl:variable name="en" select="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]"/>
                 <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                 <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
             </xsl:when>
             <xsl:when test="$doc/ancestor-or-self::tei:TEI/descendant::tei:biblStruct">
                 <xsl:variable name="title" select="$doc/ancestor-or-self::tei:TEI/descendant::tei:biblStruct/descendant::tei:title"/>
                 <xsl:value-of select="local:sortStringEn($title)"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="local:sortStringEn($doc/ancestor-or-self::tei:TEI/descendant::tei:titleStmt/tei:title[1])"/>
             </xsl:otherwise>
         </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <!-- ASK ERIN about arrays? and figure out how to do them with this damn strucutre -->
    <xsl:template match="*:fields[@function = 'series']">
        <xsl:param name="doc"/>
        <!-- seriesStmt multiple -->
        <xsl:if test="$doc/descendant::tei:seriesStmt">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">            
                <xsl:for-each select="$doc/descendant::tei:seriesStmt">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tei:title"/></string>
                </xsl:for-each>    
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'idno']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:value-of select="replace($doc/descendant::tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleSyriac']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^syr')]">
                <xsl:value-of select="string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^syr')],' ')"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][matches(@xml:lang,'^syr')]">
                <xsl:value-of select="string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][matches(@xml:lang,'^syr')][not(empty(node()))][1],' ')"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')]">
                <xsl:value-of select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][not(empty(node()))][1],' ')"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleArabic']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^ar')]">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^ar')],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][matches(@xml:lang,'^ar')]">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][matches(@xml:lang,'^ar')][not(empty(node()))][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^ar')]">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^ar')][not(empty(node()))][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:person/tei:persName[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr($doc/descendant::tei:person/tei:persName[@xml:lang = 'ar'])"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr($doc/descendant::tei:place/tei:placeName[@xml:lang = 'ar'])"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:bibl/tei:title[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr($doc/descendant::tei:bibl/tei:title[@xml:lang = 'ar'])"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:teiHeader/tei:title[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr($doc/descendant::tei:teiHeader/tei:title[@xml:lang = 'ar'])"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleFrench']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'fr'])"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][@xml:lang = 'fr'][not(empty(node()))],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:person/tei:persName[@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:person/tei:persName[@xml:lang = 'fr'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:place/tei:placeName[@xml:lang = 'fr'][1],' '))"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleTransliteration']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn($doc/descendant::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'en-x-gedsh'])"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][@xml:lang = 'en-x-gedsh'][not(empty(node()))],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:person/tei:persName[@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:person/tei:persName[@xml:lang = 'en-x-gedsh'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:place/tei:placeName[@xml:lang = 'en-x-gedsh'][1],' '))"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'author']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:biblStruct/descendant-or-self::tei:author or $doc/descendant::tei:biblStruct/descendant-or-self::tei:editor">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each select="$doc/descendant::tei:biblStruct/descendant-or-self::tei:author | $doc/descendant::tei:biblStruct/descendant-or-self::tei:editor">
                    <xsl:variable name="lastNameFirst">
                        <xsl:choose>
                            <xsl:when test="tei:surname">
                                <xsl:value-of select="concat(tei:surname, ' ', tei:forename)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="string-join(child::*,' ')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$lastNameFirst"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'cbssPublicationDate']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:imprint/tei:date">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each select="$doc/descendant::tei:imprint/tei:date">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="local:buildDate(.)"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'cbssPubPlace']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:imprint/tei:pubPlace">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each select="$doc/descendant::tei:imprint/tei:pubPlace">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="."/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'cbssPubLang']">
        <xsl:param name="doc"/>
        <xsl:variable name="author">
            <xsl:choose>
                <xsl:when test="$doc/descendant::tei:biblStruct/descendant::tei:author[1]/tei:surname">
                    <xsl:value-of select="concat($doc/descendant::tei:biblStruct/descendant::tei:author[1]/tei:surname,' ', $doc/descendant::tei:biblStruct/descendant::tei:author[1]/tei:forename)"/>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:biblStruct/descendant::tei:editor/tei:surname">
                    <xsl:value-of select="concat($doc/descendant::tei:biblStruct/descendant::tei:editor[1]/tei:surname,' ', $doc/descendant::tei:biblStruct/descendant::tei:editor[1]/tei:forename)"/>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:biblStruct/descendant::tei:author[1]">
                    <xsl:value-of select="$doc/descendant::tei:biblStruct/descendant::tei:author[1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="authorString" select="replace($author,'[^\w+]','')"/>
        <xsl:variable name="field">
            <xsl:choose>
                <xsl:when test="matches($authorString,'\p{IsBasicLatin}')">English</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsGreekandCoptic}')">Greek</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsCyrillic}')">Cyrillic</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsArabic}')">Arabic</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsHebrew}')">Hebrew</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsSyriac}')">Syriac</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsArmenian}')">Armenian</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsLatinExtended-A}')">English</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsLatinExtended-B}')">English</xsl:when>
                <xsl:when test="matches($authorString,'\p{IsLatinExtendedAdditional}')">English</xsl:when>
                <xsl:otherwise>English</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'publisher']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:publisher">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each select="$doc/descendant::tei:publisher">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="."/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:fields"/>
    <!--
    <xsl:template match="*:fields[@function = 'fullText']">
        <xsl:param name="doc"/>
        <xsl:apply-templates select="descendant::tei:body/descendant::text()"/>
    </xsl:template>
    -->
    
    <xsl:template match="t:TEI" mode="fullText">
        <xsl:apply-templates select="descendant::tei:body/descendant::text()"/>
    </xsl:template>
    <xsl:template match="t:TEI" mode="title">
        <xsl:choose>
            <xsl:when test="descendant::t:title"><xsl:value-of select="descendant::t:title[1]"/></xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Output Data as json for OpenSearch  -->
    <!-- Indexes, use facet-config files -->
    <xsl:template name="docJSON">
        <xsl:param name="doc"/>
        <xsl:variable name="xml">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                    <xsl:choose>
                        <xsl:when test="@function != ''">Function
                        <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">Test Function here</string>
                        </xsl:when>
                        <xsl:when test="@xpath != ''">
                            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:variable name="xpath" select="string(@xpath)"/>
<!--                                <xsl:evaluate xpath="$xpath"/>-->
                                <xsl:apply-templates select="$doc" mode="index">
                                    <xsl:with-param name="xpath" select="$xpath"></xsl:with-param>
                                </xsl:apply-templates>
                                <!--
                                <xsl:for-each select="$doc/descendant-or-self::t:TEI">
                                    <xsl:evaluate xpath="$xpath"/>
                                    <xsl:value-of select="local-name(.)"/> :: <xsl:value-of select="local-name(child::*[1])"/>
                                </xsl:for-each>
                                -->
                            </string> 
                        </xsl:when>
                        <xsl:otherwise>
                              <xsl:message>Incorrect field formatting</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </map>
            <!-- 
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <map key="mappings">
                        <map key="properties">
                            <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                                <map key="{.}">
                                    <string key="type">
                                        <xsl:choose>
                                            <xsl:when test="@type"><xsl:value-of select="string(@type)"/></xsl:when>
                                            <xsl:otherwise>text</xsl:otherwise>
                                        </xsl:choose>
                                    </string>
                                </map>
                            </xsl:for-each>
                        </map>
                    </map>
                </map>
            -->
        </xsl:variable>
        <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
    </xsl:template>
    
    <xsl:template mode="index" match="/t:TEI">
        <xsl:param name="xpath"></xsl:param>
        <xsl:variable name="string">    
            <xsl:evaluate xpath="$xpath"/>
        </xsl:variable>
        <xsl:value-of select="$string"/>
    </xsl:template>
    
</xsl:stylesheet>
