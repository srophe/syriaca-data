    <!-- ================================================================== 
      This stylesheet takes the json.xsl file from the syriaca and gaddel repos as its model, but for cloud use. All local paths have been changed to process data files in GitHub.
       
       Transform TEI data as json
       Uses repo-config.xml to build fields. If fields are not specified in repo-config.xml it will not be found in resulting json. 
          
       ================================================================== -->
    
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

    <!-- Strip all whitespace from elements -->
    <xsl:strip-space elements="*"/>

    <!-- Output settings -->
    <xsl:output method="text" encoding="utf-8" indent="no"/>
    
    <xsl:param name="docType" />
    <xsl:param name="configPath" select="'./repo-config.xml'"/>
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>
    
    <xsl:function name="local:format-date" as="xs:integer">
        <xsl:param name="date" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($date, '-') and matches($date, '^-\d{4}-\d{2}-\d{2}$')">
                <xsl:sequence select="xs:integer(concat('-', replace(substring($date, 2), '-', '')))"/>
            </xsl:when>
            <xsl:when test="starts-with($date, '-') and matches($date, '^-\d{4}$')">
                <xsl:sequence select="xs:integer(concat($date, '0000'))"/>
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}-\d{2}-\d{2}$')">
                <xsl:sequence select="xs:integer(replace($date, '-', ''))"/>
            </xsl:when>
            <xsl:when test="matches($date, '^\d{4}$')">
                <xsl:sequence select="xs:integer(concat($date, '0000'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/> <!-- Replace with a fallback number if necessary -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="local:sortStringEn">
        <xsl:param name="string"/>
        <xsl:variable name="title" select="normalize-space($string)"/>
        <xsl:value-of select="replace($title,'^[tT]he\s+|^\s+|^[‘|ʻ|ʿ|ʾ]|^[tT]he\s+[^\p{L}]+|^[dD]e\s+|^[dD]e-|^[oO]n\s+[aA]\s+|^[oO]n\s+|^[aA]l-|^[aA]n\s|^[aA]\s+|^\d*\W|^[^\p{L}]','')"/>    </xsl:function>
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
    <xsl:template match="*:fields[@function = 'cbssCitation']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/cbss')">
            <xsl:if test="$doc/descendant::tei:bibl[@type='formatted'][@subtype='citation']">
                <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:apply-templates select="$doc/descendant::tei:bibl[@type='formatted'][@subtype='citation']" mode="citation"/>
                </string>   
            </xsl:if>            
        </xsl:if>
    </xsl:template>
    <xsl:template match="/">
        <xsl:variable name="doc">
            <xsl:sequence select="."/>
        </xsl:variable>
        <xsl:variable name="id" select="replace($doc/descendant::tei:publicationStmt/tei:idno[@type='URI'][1],'/tei','')"/>
        <xsl:variable name="xml">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <string key="docType">
                    <xsl:value-of select="$docType"/>
                </string>
                <xsl:for-each select="$config/descendant::*:searchFields/*:fields">
                    <xsl:choose>
                        <xsl:when test="@function != ''">
                            <xsl:variable name="function" select="@function"/>
                                <xsl:apply-templates select=".[@function = $function]">
                                    <xsl:with-param select="$doc" name="doc"/>
                                    <xsl:with-param select="$id" name="id"/>
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
            <xsl:value-of select="normalize-space(string-join($doc/descendant::tei:body/descendant::text(),' '))"/>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="$field"/>
            </string>    
        </xsl:if>
    </xsl:template>
<xsl:template name="persNameSort">
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="local-name($element) = 'persName'">
                <xsl:choose>
                    <xsl:when test="$element/child::*[@sort]">
                        <xsl:variable name="sortName">
                            <xsl:for-each select="$element/child::*">
                                <xsl:sort select="@sort"/>
                                <xsl:value-of select="."/><xsl:text> </xsl:text>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:value-of select="normalize-space($sortName)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="local:sortStringEn(normalize-space(string-join($element/descendant-or-self::text(),' ')))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="local:sortStringEn(normalize-space(string-join($element/descendant-or-self::text(),' ')))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'title']">
        <xsl:param name="doc"/>
        <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
            <xsl:choose>
                <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <!--
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
                    </string>
                    -->
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:call-template name="persNameSort">
                            <xsl:with-param name="element" select="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]"/>
                        </xsl:call-template>
                    </string>
                    <xsl:if test="$doc/descendant::tei:body/tei:bibl/tei:title">
                        <xsl:for-each select="$doc/descendant::tei:body/tei:bibl/tei:title">                        
                            <string xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                            </string>
                        </xsl:for-each>    
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <!--
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
                    </string>
                    -->
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:call-template name="persNameSort">
                            <xsl:with-param name="element" select="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))]"/>
                        </xsl:call-template>
                    </string>
                    <xsl:if test="$doc/descendant::tei:body/tei:bibl/tei:title">
                        <xsl:for-each select="$doc/descendant::tei:body/tei:bibl/tei:title">                        
                            <string xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                            </string>
                        </xsl:for-each>    
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <!--
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:value-of select="local:sortStringEn(concat($en, if($syr != '') then  concat(' - ', $syr) else ()))"/>
                    </string>
                    -->
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <xsl:call-template name="persNameSort">
                            <xsl:with-param name="element" select="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]"/>
                        </xsl:call-template>
                    </string>
                    <xsl:if test="$doc/descendant::tei:body/tei:bibl/tei:title">
                        <xsl:for-each select="$doc/descendant::tei:body/tei:bibl/tei:title">                        
                            <string xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                            </string>
                        </xsl:for-each>    
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:body/tei:bibl/tei:title">
                    <xsl:for-each select="$doc/descendant::tei:body/tei:bibl/tei:title">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                        </string>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:biblStruct">
                    <xsl:for-each select="$doc/descendant::tei:biblStruct/descendant::tei:title">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                        </string>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$doc/descendant::tei:titleStmt/descendant::tei:title">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <xsl:value-of select="local:sortStringEn(string-join(.,' '))"/>
                        </string>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose> 
        </array>
    </xsl:template>
   
    <xsl:template match="*:fields[@function = 'displayTitleEnglish']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
            <xsl:choose>
                <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@syriaca-tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <xsl:value-of select="$en"/><xsl:if test="$syr != ''"> -  &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$syr"/>&lt;/span&gt;</xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <xsl:value-of select="$en"/><xsl:if test="$syr != ''"> -  &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$syr"/>&lt;/span&gt;</xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
                    <xsl:variable name="en" select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))][1]//text(),' ')"/>
                    <xsl:variable name="syr" select="string-join($doc/descendant::*[contains(@srophe:tags,'#syriaca-headword')][matches(@xml:lang,'^syr')][1],' ')"/>
                    <xsl:value-of select="$en"/><xsl:if test="$syr != ''"> -  &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$syr"/>&lt;/span&gt;</xsl:if>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:biblStruct">
                    <xsl:value-of select="string-join($doc/descendant::tei:biblStruct/child::*[tei:title[not(empty(node()))]][1]/tei:title[not(empty(node()))][1]//text(),' ')"/>
                </xsl:when>
                <xsl:when test="$doc/descendant::tei:body/tei:bibl/tei:title">
                    <xsl:value-of select="string-join($doc/descendant::tei:body/tei:bibl/tei:title[not(empty(node()))][1]//text(),' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    t1<xsl:value-of select="string-join($doc/descendant::tei:titleStmt/descendant::tei:title[not(empty(node()))][1]//text(),' ')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="normalize-space($field)"/>
            </string>    
        </xsl:if>
    </xsl:template>


<xsl:template match="*:fields[@function = 'displayTitleSyriac']">
  <xsl:param name="doc"/>
  <xsl:variable name="field">
    <xsl:choose>
      <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'syr')][not(empty(node()))]">
        <xsl:value-of select="string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][contains(@xml:lang,'syr')][not(empty(node()))][1]//text(),' ')"/>
      </xsl:when>
      <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'en')][not(empty(node()))]">
        <xsl:value-of select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][contains(@xml:lang,'syr')][not(empty(node()))][1]//text(),' ')"/>
      </xsl:when>
      <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'en')][not(empty(node()))]">
        <xsl:value-of select="string-join($doc/descendant-or-self::*[contains(@srophe:tags,'#syriaca-headword')][contains(@xml:lang,'syr')][not(empty(node()))][1]//text(),' ')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$field != ''">
    <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
      <xsl:text disable-output-escaping="yes">&lt;span lang="syr" dir="rtl"&gt;</xsl:text>
      <xsl:value-of select="normalize-space($field)"/>
      <xsl:text disable-output-escaping="yes">&lt;/span&gt;</xsl:text>
    </string>
  </xsl:if>
</xsl:template>

    <!-- Arrays appear to be properly formatted. Verify -->
    <xsl:template match="*:fields[@function = 'series']">
        <xsl:param name="doc"/>
        <!-- seriesStmt multiple -->
        <xsl:choose>
            <xsl:when test="$doc/descendant::tei:seriesStmt">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">            
                    <xsl:for-each select="$doc/descendant::tei:seriesStmt">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="string-join(tei:title,' ')"/></string>
                    </xsl:for-each>    
                </array>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:publicationStmt/tei:idno[starts-with(. , 'http://syriaca.org/cbss/')]">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">            
                    <string xmlns="http://www.w3.org/2005/xpath-functions">Comprehensive Bibliography on Syriac Studies</string>    
                </array>
            </xsl:when>
        </xsl:choose>
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
        <xsl:template match="*:fields[@function = 'type']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="contains($id, '/place')">
                <xsl:variable name="field">
                    <xsl:value-of select="$doc/descendant::tei:place/@ana"/>
                </xsl:variable>
                <xsl:for-each select="tokenize($field,' ')">
                    <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:value-of select="tokenize(.,'/')[last()]"/>
                     </string>
                 </xsl:for-each>
            </xsl:when>
            <xsl:when test="contains($id, '/person')">
              <xsl:if test="$doc/descendant::tei:body/descendant::tei:state[@type='status']">
                    <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                        <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:state[@type='status']">
                            <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize(@ref,'/')[last()]"/></string>
                        </xsl:for-each>
                    </array>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($id, '/work')">
                <xsl:if test="$doc/descendant::tei:body/descendant::tei:idno/@type[. != 'URI']">
                    <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                        <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:idno/@type[. != 'URI']">
                            <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(.,' '))"/></string>
                        </xsl:for-each>
                    </array>
                </xsl:if> 
            </xsl:when>
            <xsl:when test="contains($id, '/cbss') or contains($id, '/bibl')">
                <xsl:if test="$doc/descendant::tei:body/descendant::tei:biblStruct/@type">
                    <xsl:variable name="field">
                        <xsl:value-of select="$doc/descendant::tei:biblStruct/@type"/>
                    </xsl:variable>
                    <xsl:if test="$field != ''">
                        <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                            <xsl:value-of select="$field"/>
                        </string>    
                    </xsl:if>
                </xsl:if> 
            </xsl:when>
        </xsl:choose>
    </xsl:template>
<!--    winona's version  -->
    <xsl:template match="tei:title" mode="citation">
        <xsl:choose>
            <xsl:when test="@level = 'a'"> "<xsl:value-of select="replace(normalize-space(.),'“|”','')"/>" </xsl:when>
            <xsl:otherwise> &lt;i&gt;<xsl:value-of select="replace(normalize-space(.),'“|”','')"/>&lt;/i&gt; </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" mode="citation">
        <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
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
                <xsl:value-of select="normalize-space($field)"/>
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
            <xsl:when test="$doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'ar'],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::tei:place/tei:placeName[@xml:lang = 'ar'],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:bibl/tei:title[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::tei:bibl/tei:title[@xml:lang = 'ar'],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:teiHeader/tei:title[@xml:lang = 'ar']">
                <xsl:value-of select="local:sortStringAr(string-join($doc/descendant::tei:teiHeader/tei:title[@xml:lang = 'ar'],' '))"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="normalize-space($field)"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleFrench']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'fr'],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][@xml:lang = 'fr'][not(empty(node()))],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:person/tei:persName[@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:person/tei:persName[@xml:lang = 'fr'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'fr'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'fr']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:place/tei:placeName[@xml:lang = 'fr'][1],' '))"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="normalize-space($field)"/>
            </string>    
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'titleTransliteration']">
        <xsl:param name="doc"/>
        <xsl:variable name="field">
        <xsl:choose>
            <xsl:when test="$doc/descendant-or-self::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::*[contains(@syriaca-tags,'#syriaca-headword')][@xml:lang = 'en-x-gedsh'],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant-or-self::*[contains(@srophe:tags,'#headword')][@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::*[contains(@srophe:tags,'#headword')][@xml:lang = 'en-x-gedsh'][not(empty(node()))],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:person/tei:persName[@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:person/tei:persName[@xml:lang = 'en-x-gedsh'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:personGrp/tei:persName[@xml:lang = 'en-x-gedsh'][1],' '))"/>
            </xsl:when>
            <xsl:when test="$doc/descendant::tei:place/tei:placeName[@xml:lang = 'en-x-gedsh']">
                <xsl:value-of select="local:sortStringEn(string-join($doc/descendant::tei:place/tei:placeName[@xml:lang = 'en-x-gedsh'][1],' '))"/>
            </xsl:when>
        </xsl:choose> 
        </xsl:variable>
        <xsl:if test="$field != ''">
            <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:value-of select="normalize-space($field)"/>
            </string>    
        </xsl:if>
    </xsl:template>
     <xsl:template match="*:fields[@function = 'editor']">Add commentMore actions
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:body/tei:bibl/tei:editor[descendant::text() != ''] or $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:editor[descendant::text() != '']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                        <xsl:for-each-group select="$doc/descendant::tei:body/tei:bibl/tei:editor[descendant::text() != '']  
                            | $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:editor[descendant::text() != '']" group-by=".">
                            <xsl:variable name="lastNameFirst">
                                <xsl:choose>
                                    <xsl:when test="tei:surname">
                                        <xsl:value-of select="concat(tei:surname, ' ', tei:forename)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <string xmlns="http://www.w3.org/2005/xpath-functions">
                                <xsl:choose>
                                    <xsl:when test="starts-with(@xml:lang,'sy')">
                                        &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$lastNameFirst"/>&lt;/span&gt;
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$lastNameFirst"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </string>
                        </xsl:for-each-group>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'author']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:body/tei:bibl/tei:author[descendant::text() != '']  Add commentMore actions
            or $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:author[descendant::text() != '']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:choose>
                    <xsl:when test="$doc/descendant::tei:body/tei:bibl/tei:author[descendant::text() != ''] 
                        or $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:author[descendant::text() != '']">
                        <xsl:for-each-group select="$doc/descendant::tei:body/tei:bibl/tei:author[descendant::text() != '']  
                            | $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:author[descendant::text() != '']" group-by=".">
                            <xsl:variable name="lastNameFirst">
                                <xsl:choose>
                                    <xsl:when test="tei:surname">
                                        <xsl:value-of select="concat(tei:surname, ' ', tei:forename)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <string xmlns="http://www.w3.org/2005/xpath-functions">Add commentMore actions
                                <xsl:choose>
                                    <xsl:when test="starts-with(@xml:lang,'sy')">
                                        &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$lastNameFirst"/>&lt;/span&gt;
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$lastNameFirst"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </string>               
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each-group select="$doc/descendant::tei:body/tei:bibl/tei:author[descendant::text() != ''] 
                            | $doc/descendant::tei:body/tei:biblStruct/descendant-or-self::tei:author[descendant::text() != '']" group-by=".">
                            <xsl:variable name="lastNameFirst">
                                <xsl:choose>
                                    <xsl:when test="tei:surname">
                                        <xsl:value-of select="concat(tei:surname, ' ', tei:forename)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                             <string xmlns="http://www.w3.org/2005/xpath-functions">Add commentMore actions
                                <xsl:choose>
                                    <xsl:when test="starts-with(@xml:lang,'sy')">
                                        &lt;span lang="syr" dir="rtl"&gt;<xsl:value-of select="$lastNameFirst"/>&lt;/span&gt;
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$lastNameFirst"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </string>       
                        </xsl:for-each-group>
                    </xsl:otherwise>
                </xsl:choose>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'subject']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:relation[@ref='dc:subject']/tei:desc[. != '']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each select="$doc/descendant::tei:relation[@ref='dc:subject']/tei:desc[. != '']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(.,' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
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
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(.,' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
 <xsl:template match="*:fields[@function = 'persName']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/person')">
            <xsl:if test="$doc/descendant::tei:body/tei:listPerson/tei:person/tei:persName or $doc/descendant::tei:body/tei:listPerson/tei:personGrp/tei:persName">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions"> 
                    <xsl:for-each-group select="$doc/descendant::tei:body/tei:listPerson/tei:person/tei:persName[descendant-or-self::text() != ''] | $doc/descendant::tei:body/tei:listPerson/tei:personGrp/tei:persName[descendant-or-self::text() != '']" group-by=".">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                            <xsl:apply-templates select="." mode="xmlLang"/>
                        </string>
                    </xsl:for-each-group>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*:fields[@function = 'placeName']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:body/tei:listPlace/tei:place/tei:placeName">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions"> 
                <xsl:for-each-group select="$doc/descendant::tei:body/tei:listPlace/tei:place/tei:placeName[descendant-or-self::text() != '']" group-by=".">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
                </xsl:for-each-group>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'location']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:location">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                <xsl:for-each-group select="$doc/descendant::tei:body/descendant::tei:location" group-by=".">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
                </xsl:for-each-group>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'event']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:event[@type != 'attestation']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:event[@type != 'attestation']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <!--<xsl:value-of select="normalize-space(string-join(.,' '))"/>-->
                            <xsl:apply-templates select="." mode="xmlLang"/>
                        </string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'attestations']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:event[@type = 'attestation']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:event[@type = 'attestation']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <!--<xsl:value-of select="normalize-space(string-join(.,' '))"/>-->
                            <xsl:apply-templates select="." mode="xmlLang"/>
                        </string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'religiousCommunities']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:state[@type = 'confession']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:state[@type = 'confession']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions">
                            <!--<xsl:value-of select="normalize-space(string-join(.,' '))"/>-->
                            <xsl:apply-templates select="." mode="xmlLang"/>
                        </string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'coordinates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:variable name="coords">
                <xsl:choose>
                    <xsl:when test="$doc/descendant::tei:location[@subtype = 'preferred']">
                        <xsl:value-of select="$doc/descendant::tei:location[@subtype = 'preferred']/tei:geo"/>
                    </xsl:when>
                    <xsl:when test="$doc/descendant::tei:geo">
                        <xsl:value-of select="$doc/descendant::tei:geo[1]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$coords != ''">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">      
                    <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[2]"/></number>
                    <number xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize($coords,' ')[1]"/></number>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'gender']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/person')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:gender">    
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">  
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:gender">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize(normalize-space(string-join(@ana,' ')),'/')[last()]"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'stateType']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:state[@type]">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each-group select="$doc/descendant::tei:body/descendant::tei:state[@type]" group-by="@type">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(@type,' '))"/></string>
                </xsl:for-each-group>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'state']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:state[normalize-space(string-join(descendant-or-self::text(),'')) != '']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:state[normalize-space(string-join(descendant-or-self::text(),'')) != '']">
                    <xsl:choose>
                        <xsl:when test="@ref">
                            <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="tokenize(@ref,'/')[last()]"/></string>
                        </xsl:when>
                        <xsl:otherwise><string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*:fields[@function = 'BHO']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='BHO']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='BHO']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'BHS']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='BHS']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='BHS']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'CPG']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='CPG']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:idno[@type='BHS']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'prologue']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='prologue']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='prologue']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'incipit']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='incipit']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='incipit']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'explicit']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='explicit']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:note[@type='explicit']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions">
                        <!--<xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/>-->
                        <xsl:apply-templates select="." mode="xmlLang"/>
                    </string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'editions']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='lawd:Edition']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='lawd:Edition']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'modernTranslations']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:ModernTranslation']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:ModernTranslation']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'ancientVersion']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:AncientVersion']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:AncientVersion']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'manuscripts']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:Manuscript']">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl[@type='syriaca:Manuscript']">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'reference']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
        <xsl:if test="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl">
            <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:bibl/tei:bibl">
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space(string-join(descendant-or-self::text(),' '))"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'bhseType']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/work')">
            <xsl:if test="$doc/descendant::tei:body/descendant::tei:idno/@type[. != 'URI']">
                <array key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">     
                    <xsl:for-each select="$doc/descendant::tei:body/descendant::tei:idno/@type[. != 'URI']">
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="."/></string>
                    </xsl:for-each>
                </array>
           </xsl:if>            
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:fields[@function = 'citation']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/cbss')">
            <xsl:if test="$doc/descendant::tei:bibl[@type='formatted'][@subtype='citation']">
                <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:apply-templates select="$doc/descendant::tei:bibl[@type='formatted'][@subtype='citation']" mode="citation"/>
<!--                    <xsl:value-of select="normalize-space(string-join($doc/descendant::tei:bibl[@type='formatted'][@subtype='citation'],' '))"/>-->
                </string>   
            </xsl:if>            
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:title" mode="citation">
        <xsl:choose>
            <xsl:when test="@level = 'a'"> "<xsl:value-of select="replace(normalize-space(.),'“|”','')"/>" </xsl:when>
            <xsl:otherwise> &lt;i&gt;<xsl:value-of select="replace(normalize-space(.),'“|”','')"/>&lt;/i&gt; </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" mode="citation">
        <xsl:text> </xsl:text><xsl:value-of select="replace(normalize-space(.),'“|”','')"/><xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'abstract']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="$doc/descendant::*[starts-with(@xml:id,'abstract')]">
                <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                    <!--<xsl:value-of select="normalize-space(string-join($doc/descendant::*[starts-with(@xml:id,'abstract')],' '))"/>-->
                    <xsl:apply-templates select="$doc/descendant::*[starts-with(@xml:id,'abstract')]" mode="xmlLang"/>
                </string>  
            </xsl:when>
            <xsl:when test="$doc/descendant::*[@type='abstract']">
                <string key="{.}" xmlns="http://www.w3.org/2005/xpath-functions">
                    <!--<xsl:value-of select="normalize-space(string-join($doc/descendant::*[@type='abstract'],' '))"/>-->
                    <xsl:apply-templates select="$doc/descendant::*[@type='abstract']" mode="xmlLang"/>
                </string>
            </xsl:when>
        </xsl:choose>    
    </xsl:template>
    <!-- DATES start and end  -->
    <xsl:template match="*:fields[@function = 'cbssPubDate']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:imprint/tei:date">  
            <array key="cbssPubDateStart" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:imprint/tei:date">
                    <xsl:variable name="date" select="normalize-space(.)"/>
                    <xsl:variable name="startDate">
                        <xsl:choose>
                            <xsl:when test="matches($date,'\d{4}-\d{4}')">
                                <xsl:value-of select="substring-before($date,'-')"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                </xsl:for-each>
            </array>
            <array key="cbssPubDateEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:imprint/tei:date">
                    <xsl:variable name="date" select="."/>
                    <xsl:variable name="endDate">
                        <xsl:choose>
                            <xsl:when test="matches($date,'\d{4}-\d{4}')">
                                <xsl:value-of select="substring-after($date,'-')"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'eventDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:event[@type != 'attestation'][@srophe:computed-start or @from or @when or @to]">
                <array key="eventDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:event[@type != 'attestation'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="startDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                    </xsl:for-each>
                </array>
                <array key="eventDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:event[@type != 'attestation'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="endDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'attestationsDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:event[@type = 'attestation'][@srophe:computed-start or @from or @when or @to]">
                <array key="attestationsDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:event[@type = 'attestation'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="startDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                    </xsl:for-each>
                </array>
                <array key="attestationsDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:event[@type = 'attestation'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="endDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'religiousCommunitiesDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:state[@type = 'confession'][@srophe:computed-start or @from or @when or @to]">
                <array key="religiousCommunitiesDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:state[@type = 'confession'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="startDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                    </xsl:for-each>
                </array>
                <array key="religiousCommunitiesDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:state[@type = 'confession'][@srophe:computed-start or @from or @when or @to]">
                        <xsl:variable name="endDate">
                            <xsl:choose>
                                <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                                <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                                <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                                <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                                <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'existenceDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="contains($id, '/place')">
            <xsl:if test="$doc/descendant::tei:state[@type = 'existence'][@srophe:computed-start]">
                <array key="existenceDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:state[@type = 'existence']">
                        <xsl:variable name="startDate" select="@srophe:computed-start"/>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                    </xsl:for-each>
                </array>
                <array key="existenceDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                    <xsl:for-each select="$doc/descendant::tei:state[@type = 'existence']">
                        <xsl:variable name="endDate" select="@srophe:computed-end"/>
                        <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'stateDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
            <xsl:if test="$doc/descendant::tei:state[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
                <array key="stateDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:state[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
                    <xsl:variable name="startDate">
                        <xsl:choose>
                            <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                            <xsl:when test="@notBefore"><xsl:value-of select="@notBefore"/></xsl:when>
                            <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                            <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                            <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                            <xsl:when test="@notAfter"><xsl:value-of select="@notAfter"/></xsl:when>
                            <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                </xsl:for-each>
            </array>
                <array key="stateDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:state[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
                    <xsl:variable name="endDate">
                        <xsl:choose>
                            <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                            <xsl:when test="@notAfter"><xsl:value-of select="@notAfter"/></xsl:when>
                            <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                            <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                            <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                            <xsl:when test="@notBefore"><xsl:value-of select="@notBefore"/></xsl:when>
                            <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'floruitDates']">
        <xsl:param name="doc"/>
        <xsl:param name="id"/>
        <xsl:if test="$doc/descendant::tei:floruit/tei:date[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
            <array key="floruitDatesStart" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:floruit/tei:date[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
                    <xsl:variable name="startDate">
                        <xsl:choose>
                            <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                            <xsl:when test="@notBefore"><xsl:value-of select="@notBefore"/></xsl:when>
                            <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                            <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                            <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                            <xsl:when test="@notAfter"><xsl:value-of select="@notAfter"/></xsl:when>
                            <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$startDate"/></string>
                </xsl:for-each>
            </array>
            <array key="floruitDatesEnd" xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$doc/descendant::tei:floruit/tei:date[@srophe:computed-start or @from or @when or @to or @notBefore or @notAfter]">
                    <xsl:variable name="endDate">
                        <xsl:choose>
                            <xsl:when test="@srophe:computed-end"><xsl:value-of select="@srophe:computed-end"/></xsl:when>
                            <xsl:when test="@notAfter"><xsl:value-of select="@notAfter"/></xsl:when>
                            <xsl:when test="@to"><xsl:value-of select="@to"/></xsl:when>
                            <xsl:when test="@when"><xsl:value-of select="@when"/></xsl:when>
                            <xsl:when test="@from"><xsl:value-of select="@from"/></xsl:when>
                            <xsl:when test="@notBefore"><xsl:value-of select="@notBefore"/></xsl:when>
                            <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$endDate"/></string>
                </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:fields[@function = 'birth']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:birth/tei:date">  
            <array key="birth" xmlns="http://www.w3.org/2005/xpath-functions">
            <xsl:for-each select="$doc/descendant::tei:birth/tei:date">
                <xsl:variable name="date">
                    <xsl:choose>
                        <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space($date)"/></string>
            </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:fields[@function = 'death']">
        <xsl:param name="doc"/>
        <xsl:if test="$doc/descendant::tei:death/tei:date">     
            <array key="death" xmlns="http://www.w3.org/2005/xpath-functions">
            <xsl:for-each select="$doc/descendant::tei:death/tei:date">
                <xsl:variable name="date">
                    <xsl:choose>
                        <xsl:when test="@srophe:computed-start"><xsl:value-of select="@srophe:computed-start"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <string xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="normalize-space($date)"/></string>
            </xsl:for-each>
            </array>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*:fields"/>
      
    <xsl:template match="t:TEI" mode="fullText">
        <xsl:value-of select="normalize-space(string-join(descendant::tei:body/descendant::text(),' '))"/>
    </xsl:template>
    <xsl:template match="t:TEI" mode="title">
        <xsl:choose>
            <xsl:when test="descendant::t:title"><xsl:value-of select="descendant::t:title[1]"/></xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Match everything, output lang tags.  -->
    <xsl:template match="*" mode="xmlLang">
        <xsl:choose>
            <xsl:when test="starts-with(@xml:lang, 'sy)"> &lt;span lang="syr" dir="rtl"&gt;<xsl:apply-templates mode="xmlLang"/>&lt;/span&gt;</xsl:when>
            <xsl:otherwise><xsl:text> </xsl:text><xsl:apply-templates mode="xmlLang"/><xsl:text> </xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" mode="xmlLang">
        <xsl:value-of select="normalize-space(string-join(.,' '))"/>
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
