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

 <!-- ================================================================== 
      staticHTML.xsl
       
       Generate Static HTML pages for TEI display  
        
       code by: 
        + Winona Salesky (wsalesky@gmail.com)
          
       funding provided by:
        + National Endowment for the Humanities (http://www.neh.gov). Any 
          views, findings, conclusions, or recommendations expressed in 
          this code do not necessarily reflect those of the National 
          Endowment for the Humanities.
       
       ================================================================== -->
 <!-- =================================================================== -->
 <!-- import component stylesheets for HTML page portions -->
 <!-- =================================================================== -->
    <xsl:import href="syriaca/resources/xsl/tei2html.xsl"/>
    <xsl:import href="./maps.xsl"/>
<!--    <xsl:import href="json.xsl"/>-->
<!--    <xsl:import href="relationships.xsl"/>-->
    
 <!-- =================================================================== -->
 <!-- set output so we get (mostly) indented HTML -->
 <!-- =================================================================== -->
    <xsl:output name="html" encoding="UTF-8" method="xhtml" indent="no" omit-xml-declaration="yes"/>    
    
    <!-- 
    Step 1: 
    create HTML page outline
        include header
        include nav for submodule
        transform HTML
        Add Footer
        
        Add dynamic (javascript calls to RDF or other related items)
        
        -->
 
    <!-- =================================================================== -->
    <!-- Parameters for tei2HTML -->
    <!-- =================================================================== -->
    
    <xsl:param name="applicationPath" select="'syriaca'"/> <!-- Refers to the syriaca repo -->
    <xsl:param name="staticSitePath" select="'syriaca/siteGenerator'"/>  
    <xsl:param name="dataPath" select="'data/'"/>  <!-- Points to the data folder -->
    <xsl:param name="configPath" select="'syriaca/siteGenerator/components/repo-config.xml'"/>  <!-- Path to config file in syriaca repo -->

    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>

    
    <!-- Parameters passed from global.xqm (set in config.xml) default values if params are empty -->
    <!-- Not needed? -->
    <xsl:param name="data-root" select="$dataPath"/>
    <!-- eXist app root for app deployment-->
    <!-- Not needed? -->
    <xsl:param name="app-root" select="$applicationPath"/>
    <!-- Root of app for building dynamic links. Default is eXist app root -->
    <!-- Not needed? -->
    <xsl:param name="nav-base" select="'/'"/>
    
    <!-- Base URI for identifiers in app data -->
    <xsl:param name="base-uri" select="'http://syriaca.org'"/>
    
    <!-- Hard coded values-->
    <xsl:param name="normalization">NFKC</xsl:param>
    <!-- Repository Title -->
    <xsl:variable name="repository-title">
        <xsl:choose>
            <xsl:when test="$config/child::*">
                <xsl:value-of select="$config/descendant::*:title[1]"/>
            </xsl:when>
            <xsl:otherwise>The Srophé Application</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="collection-title">
        <xsl:choose>
            <xsl:when test="$config/child::*">
                <xsl:choose>
                    <xsl:when test="$config/descendant::*:collection[@name=$collection]">
                        <xsl:value-of select="$config/descendant::*:collection[@name=$collection]/@title"/>
                    </xsl:when>
                    <xsl:when test="$config/descendant::*:collection[@title=$collection]">
                        <xsl:value-of select="$config/descendant::*:collection[@title=$collection]/@title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$repository-title"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$repository-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Resource id -->
    <xsl:variable name="resource-id">
        <xsl:choose>
            <xsl:when test="string(/*/@id)">
                <xsl:value-of select="string(/*/@id)"/>
            </xsl:when>
            <xsl:when test="/descendant::t:publicationStmt/t:idno[@type='URI'][starts-with(.,$base-uri)]">
                <xsl:value-of select="replace(replace(/descendant::t:publicationStmt[1]/t:idno[@type='URI'][starts-with(.,$base-uri)][1],'/tei',''),'/source','')"/>
            </xsl:when>
            <xsl:when test="/descendant::t:publicationStmt/t:idno[@type='URI']">
                <xsl:value-of select="replace(replace(/descendant::t:publicationStmt[1]/t:idno[@type='URI'][1],'/tei',''),'/source','')"/>
            </xsl:when>
            <xsl:when test="/descendant::t:idno[@type='URI'][starts-with(.,$base-uri)]">
                <xsl:value-of select="replace(replace(/descendant::t:idno[@type='URI'][starts-with(.,$base-uri)][1],'/tei',''),'/source','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($base-uri,'/0000')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Resource title -->
    <xsl:variable name="resource-title">
        <xsl:choose>
            <xsl:when test="/descendant::t:text/t:body[descendant::*[@srophe:tags = '#syriaca-headword2']]">
                <xsl:apply-templates select="/descendant::t:text/t:body[descendant::*[@srophe:tags = '#syriaca-headword']][@xml:lang = 'en']/text()"/>
            </xsl:when>
            <!--
            <xsl:when test="contains(/descendant::t:title[1]/text(),' — ')">
                <xsl:apply-templates select="substring-before(/descendant::t:title[1],' — ')"/>
            </xsl:when>
            -->
            <xsl:otherwise>
                <xsl:apply-templates select="/descendant-or-self::t:titleStmt/t:title[1]"/>                
            </xsl:otherwise>            
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="resource-path" select="substring-after(document-uri(.),':')"/>
        
    <!-- Collection variables from repo-config -->
    <!-- 
        <collection name="authors" 
        title="A Guide to Syriac Authors" 
        collection-URI="http://syriaca.org/authors" 
        series="The Syriac Biographical Dictionary" 
        app-root="/authors/" 
        data-root="persons" 
        record-URI-pattern="http://syriaca.org/person/"/> -->
    <xsl:variable name="collectionURIPattern">
        <xsl:if test="$resource-id != ''"><xsl:for-each select="tokenize($resource-id,'/')"><xsl:if test="position() != last()"><xsl:value-of select="concat(.,'/')"/></xsl:if></xsl:for-each></xsl:if>
    </xsl:variable>
    <xsl:variable name="collectionValues" select="$config/descendant::*:collection[matches(@record-URI-pattern,concat('^',$collectionURIPattern))][1]"/>
    <xsl:variable name="collectionTemplate">
        <xsl:if test="doc-available(xs:anyURI(concat($staticSitePath,'/components/',string($collectionValues/@template),'.html')))">
            <xsl:sequence select="document(xs:anyURI(concat($staticSitePath,'/components/',string($collectionValues/@template),'.html')))"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="collection" select="$collectionValues/@name"/>

    <!-- Figure out if document is HTML or TEI -->
    <xsl:template match="/">
        <xsl:variable name="documentURI" select="document-uri(.)"/>
        <xsl:variable name="fileType">
            <xsl:choose>
                <xsl:when test="/html:div[@data-template-with]">HTML</xsl:when>
                <xsl:when test="/t:TEI">TEI</xsl:when>
                <xsl:when test="/t:TEI">TEI</xsl:when>
                <xsl:otherwise>OTHER: <xsl:value-of select="name(root(.))"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="filename">
            <xsl:value-of select="replace(tokenize($documentURI,'/')[last()],'.xml','.html')"/>
        </xsl:variable>
        <xsl:variable name="path">
            <xsl:choose>
                <xsl:when test="$fileType = 'HTML'">
                    <xsl:value-of select="$resource-path"/>
                </xsl:when>
                <xsl:when test="$fileType = 'TEI'">
                    <xsl:value-of select="$resource-path"/>
                </xsl:when>
                <xsl:otherwise><xsl:message>Unrecognizable file type <xsl:value-of select="$fileType"/> [<xsl:value-of select="$documentURI"/>]</xsl:message></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       <!-- TEST vars -->
        <!--
        resource-id : <xsl:value-of select="$resource-id"/>
        collection-pattern : <xsl:value-of select="$collectionURIPattern"/>
        resource-path : <xsl:value-of select="$resource-path"/>
        config: <xsl:sequence select="$config/descendant::*:collection[matches(@record-URI-pattern,concat('^',$collectionURIPattern))][1]"/>
        collectionValues : <xsl:sequence select="$collectionValues"/>
        collectionTemplate: <xsl:value-of select="concat($staticSitePath,'/siteGenerator/components/',string($collectionValues/@template))"/>
        Doc <xsl:sequence select="$collectionTemplate"></xsl:sequence>
        -->
       
      

        <!-- Extract the filename and replace .xml with .html -->
        <xsl:variable name="filename">
            <xsl:value-of select="replace(tokenize(document-uri(.),'/')[last()],'.xml','.html')"/>
        </xsl:variable>
        <!-- Tokenize the path -->
        <xsl:variable name="tokens" select="tokenize($resource-path, '/')"/>

        <!-- Find the second word -->
        <xsl:variable name="second-token" select="$tokens[2]"/>

        <!-- Find the last three folders -->
        <xsl:variable name="last-three-folders" select="concat($tokens[last()-2], '/', $tokens[last()-1], '/', $tokens[last()])"/>

        <xsl:value-of select="$last-three-folders"/>

        <xsl:variable name="type" select="replace($last-three-folders, '.*/(person|work|place|subject|spear|bibl)/.*', '$1')" />

        <!-- Output the HTML to the appropriate folder (work, person, place) -->
        <xsl:result-document href="{$type}/${filename}">
            <xsl:choose>
                <xsl:when test="$fileType = 'HTML'">
                    <xsl:call-template name="htmlPage">
                        <xsl:with-param name="pageType" select="'HTML'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$fileType = 'TEI'">
                    <xsl:call-template name="htmlPage">
                        <xsl:with-param name="pageType" select="'TEI'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Unrecognizable file type <xsl:value-of select="$fileType"/></xsl:message>
                </xsl:otherwise>    
            </xsl:choose>
        </xsl:result-document>
          <!--  
        <xsl:if test="$fileType = 'TEI'">
            <xsl:result-document href="{replace(replace($path,'/data/','/json/'),'.xml','.json')}">
                <xsl:call-template name="docJSON">
                    <xsl:with-param name="doc" select="root(.)/descendant-or-self::t:TEI"/>
                </xsl:call-template>
            </xsl:result-document>
        </xsl:if>
        -->
    </xsl:template>
    
    <xsl:template name="htmlPage">
        <xsl:param name="pageType"/>
        <!-- <xsl:apply-templates/> -->
        <html xmlns="http://www.w3.org/1999/xhtml">
            <!-- HTML Header, use templates as already estabilished, if no template exists, use generic -->
            <xsl:variable name="template">
                <xsl:choose>
                    <xsl:when test="$pageType = 'HTML'">
                        <xsl:variable name="templatePath"><xsl:value-of select="string(/*:div/@data-template-with)"/></xsl:variable>
                        <xsl:if test="doc-available(concat($staticSitePath,replace($templatePath,'/templates/','/components/')))">
                            <xsl:sequence select="document(concat($staticSitePath,replace($templatePath,'/templates/','/components/')))"/>
                        </xsl:if>    
                    </xsl:when>
                    <xsl:when test="$pageType = 'TEI'">
                       <xsl:choose>
                           <xsl:when test="$collectionTemplate/child::*">
                               <xsl:sequence select="$collectionTemplate"/> 
                           </xsl:when>
                           <xsl:otherwise><xsl:message>Error Can not find matching template for TEI type </xsl:message></xsl:otherwise>
                       </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$template/child::*">
                    <xsl:choose>
                        <xsl:when test="$template/descendant::*:head">
                             <xsl:copy-of select="$template/descendant::*:head"/>
<!--                            <xsl:apply-templates select="$template/descendant::html:head"/>-->
                        </xsl:when>
                        <xsl:otherwise><xsl:message>Error in template, check template for html:head </xsl:message></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:call-template name="genericHeader"/></xsl:otherwise>
            </xsl:choose>
            <body id="body">
                <xsl:choose>
                    <xsl:when test="not(empty($template))">
                        <xsl:choose>
                            <xsl:when test="$template/descendant::html:nav">
                                <xsl:copy-of select="$template/descendant::html:nav"/>
<!--                                <xsl:apply-templates select="$template/descendant::html:nav"/>-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="genericNav"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="genericNav"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$pageType = 'html'">
                        <xsl:copy-of select="."></xsl:copy-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--
                        <xsl:choose>
                            <xsl:when test="$collectionTemplate">
                                <xsl:apply-templates select="t:TEI"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="genericTEIPage"/>
                            </xsl:otherwise>
                        </xsl:choose>
                -->
                        <xsl:call-template name="genericTEIPage">
                            <xsl:with-param name="config" select="$config"></xsl:with-param>
                            <xsl:with-param name="repository-title" select="$repository-title"/>
                            <xsl:with-param name="collection-title" select="$collection-title"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="doc-available(xs:anyURI(concat($staticSitePath,'/components/footer.html')))">
                    <xsl:copy-of select="document(xs:anyURI(concat($staticSitePath,'/components/footer.html')))"/>
                </xsl:if>
            </body>
            <xsl:if test="$template/child::*[1]/html:script">
                <xsl:copy-of select="$template/child::*[1]/html:script"/>
            </xsl:if>
        </html>
    </xsl:template>
     
    <xsl:template match="html:li">
        <xsl:choose>
            <xsl:when test="@data-template='app:shared-content'">
                <xsl:variable name="sharedContent" select="@data-template-path"/>
                <xsl:if test="doc-available(xs:anyURI(concat($staticSitePath,'/components/',tokenize($sharedContent,'/')[last()])))">
                    <xsl:copy-of select="document(xs:anyURI(concat($staticSitePath,'/components/',tokenize($sharedContent,'/')[last()])))"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="@*">
                        <xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
                    </xsl:for-each>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="html:span">
        <xsl:choose>
            <xsl:when test="@data-template='app:keyboard-select-menu'">
                <xsl:variable name="inputID" select="@data-template-input-id"/>
                <xsl:choose>
                    <xsl:when test="$config/descendant::*:keyboard-options/child::*">
                        <span class="keyboard-menu" xmlns="http://www.w3.org/1999/xhtml">
                            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Select Keyboard">
                                &#160;<span class="syriaca-icon syriaca-keyboard">&#160; </span><span class="caret"/>
                            </button>
                            <ul class="dropdown-menu">
                                <xsl:for-each select="$config/descendant::*:keyboard-options/*:option">
                                    <li xmlns="http://www.w3.org/1999/xhtml"><a href="#" class="keyboard-select" id="{@id}" data-keyboard-id="{$inputID}"><xsl:value-of select="."/></a></li>
                                </xsl:for-each>
                            </ul>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="generickeyboardSelect"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="@*">
                        <xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
                    </xsl:for-each>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="html:link | html:script | html:a">
        <xsl:element name="{name()}">
            <!--<link rel="stylesheet" type="text/css" href="$nav-base/resources/css/syr-icon-fonts.css"/>-->
            <xsl:copy-of select="@*[not(local-name() = 'href')]"/>
            <xsl:if test="@href">
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(@href,'$nav-base/')">
                            <xsl:value-of select="replace(@href,'$nav-base/','/')"/>
                        </xsl:when>
                        <xsl:when test="not(starts-with(@href,'/'))">
                            <xsl:value-of select="concat('/',@href)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@href"/>
                        </xsl:otherwise>
                    </xsl:choose>    
                </xsl:variable>
                <xsl:attribute name="href" select="$href"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="otherDataFormats">
        <xsl:param name="node"/>
        <xsl:param name="formats"/>
        <xsl:variable name="dataPath" select="substring-before(concat($staticSitePath,'/data/',replace($resource-path,$dataPath,'')),'.xml')"></xsl:variable>
        <xsl:if test="$formats != ''">
            <div class="container otherFormats" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:for-each select="tokenize($formats,',')">
                    <xsl:choose>
                        <xsl:when test=". = 'geojson'">
                            <a href="{concat($dataPath,'.geojson')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the GeoJSON data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> GeoJSON
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'json'">
                            <a href="{concat($dataPath,'.json')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the GeoJSON data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> JSON-LD
                            </a><xsl:text>&#160;</xsl:text> 
                        </xsl:when>
                        <xsl:when test=". = 'kml'">
                            <xsl:if test="$node/descendant::t:location/t:geo">
                                <a href="{concat($dataPath,'.kml')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the KML data for this record." >
                                    <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> KML
                                </a><xsl:text>&#160;</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test=". = 'print'">
                            <a href="javascript:window.print();" type="button" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to send this page to the printer." >
                                <span class="glyphicon glyphicon-print" aria-hidden="true"></span>
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'rdf'">
                            <a href="{concat($dataPath,'.rdf')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the RDF-XML data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> RDF/XML
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'tei'">
                            <a href="{concat($dataPath,'.tei')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the TEI XML data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> TEI/XML
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'text'">
                            <a href="{concat($dataPath,'.txt')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the plain text data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> Text
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'citations'">
                            <xsl:variable name="zoteroGrp" select="$config/descendant::*:zotero/@group"/>
                            <xsl:if test="$zoteroGrp != ''">
                                (<a href="{concat('https://api.zotero.org/groups/',$zoteroGrp,'/items/',tokenize($resource-id,'/')[last()])}" class="btn btn-default btn-xs" id="citationsBtn" data-toggle="tooltip" title="Click for additional Citation Styles." >
                                    <span class="glyphicon glyphicon-th-list" aria-hidden="true"></span> Cite
                                </a><xsl:text>&#160;</xsl:text>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="genericTEIPage">
        <xsl:param name="config"/>
        <xsl:param name="repository-title"/>
        <xsl:param name="collection-title"/>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <div class="main-content-block">
                <div class="interior-content">
                    <xsl:call-template name="otherDataFormats">
                        <xsl:with-param name="node" select="t:TEI"/>
<!--                        <xsl:with-param name="formats" select="'print,tei,rdf,text'"/>-->
                        <xsl:with-param name="formats" select="'print,tei'"/>
                    </xsl:call-template>
                    <div class="row">
                        <div class="col-md-7 col-lg-8">
                            <xsl:apply-templates select="t:TEI"/>
                            <!--
                            <xsl:apply-templates select="t:TEI">
                                <xsl:with-param name="config" select="$config"/>
                                <xsl:with-param name="repository-title" select="$repository-title"/>
                                <xsl:with-param name="collection-title" select="$collection-title"/>
                            </xsl:apply-templates>
                            -->
                        </div>
                        <div class="col-md-5 col-lg-4 right-menu">
                            <!-- Make dynamic -->
                            <!-- WS:ToDo Maps -->
                            <xsl:choose>
                                <xsl:when test="descendant::t:geo">
                                    <xsl:call-template name="leafletMap">
                                        <xsl:with-param name="nodes" select="/t:TEI"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <!-- Maps for related places -->
                                
                            </xsl:choose>
                            <br/>
                            <!-- WS:Note need to wait for RDF, not sure how to resolve paths to files from URI, they are not dependable paths (NHSL for example) -->
                            <!-- 
                            <xsl:choose>
                                <xsl:when test="descendant::t:relation">
                                    <xsl:call-template name="leafletMap">
                                        <xsl:with-param name="nodes" select="/t:TEI"/>
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                            -->
                            <!-- Relationsips listed in the TEI record  display: list/sentence -->
                            <!-- WS:ToDo Relationships -->
<!--                            <div data-template="app:internal-relationships" data-template-label="Internal Relationships"/>-->
                            <!-- Relationships referencing this TEI record -->
                            <!--                    <div data-template="app:external-relationships" data-template-label="External Relationships"/>    -->
                        </div>
                    </div>
                </div>
            </div>
            <!-- Modal email form-->
            <!-- WS:ToDo Contact form?  -->
<!--            <div data-template="app:contact-form" data-template-collection="places"/>-->
            <xsl:if test="t:TEI/descendant::t:geo">
                <script type="text/javascript" src="/resources/leaflet/leaflet.js"/>
                <script type="text/javascript" src="/resources/js/maps.js"/>                
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template name="genericHeader">
        <head xmlns="http://www.w3.org/1999/xhtml">
            <title>Generic Header:: <xsl:value-of select="$resource-title"/></title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta name="DC.type" property="dc.type" content="Text"/>
            <meta name="DC.isPartOf" property="dc.ispartof" content="{$config/html:title[1]}"/>
            <link rel="shortcut icon" href="/resources/images/fav-icons/syriaca-favicon.ico"/>
            <!-- Bootstrap 3 -->
            <link rel="stylesheet" type="text/css" href="/resources/bootstrap/css/bootstrap.min.css"/>
            <link rel="stylesheet" type="text/css" href="/resources/css/sm-core-css.css"/>
            <!-- Srophe styles -->
            <link rel="stylesheet" type="text/css" href="/resources/css/syr-icon-fonts.css"/>
            <link rel="stylesheet" type="text/css" href="/resources/css/style.css"/>
            <link rel="stylesheet" type="text/css" href="/resources/css/syriaca.css"/>
            <link rel="stylesheet" type="text/css" href="/resources/css/slider.css"/>
            <link rel="stylesheet" type="text/css" href="/resources/css/lightslider.css"/>
            <link rel="stylesheet" type="text/css" media="print" href="/resources/css/print.css"/>
            <!-- Leaflet -->
            <link rel="stylesheet" href="/resources/leaflet/leaflet.css"/>
            <link rel="stylesheet" href="/resources/leaflet/leaflet.awesome-markers.css"/>
            <script defer="defer" data-domain="syriaca.org" src="https://plausible.io/js/plausible.js"/>
            <!-- JQuery -->
            <link href="/resources/jquery-ui/jquery-ui.min.css" rel="stylesheet"/>
            <script type="text/javascript" src="/resources/js/jquery.min.js"/>
            <script type="text/javascript" src="/resources/jquery-ui/jquery-ui.min.js"/>
            <script type="text/javascript" src="/resources/js/jquery.smartmenus.min.js"/>
            <script type="text/javascript" src="/resources/js/clipboard.min.js"/>
            <!-- Bootstrap -->
            <script type="text/javascript" src="/resources/bootstrap/js/bootstrap.min.js"/>
            <!-- ReCaptcha -->
            <script src="https://www.google.com/recaptcha/api.js" type="text/javascript" async="async" defer="defer"/>
            <!-- keyboard widget css & script -->
            <link href="/resources/keyboard/css/keyboard.min.css" rel="stylesheet"/>
            <link href="/resources/keyboard/css/keyboard-previewkeyset.min.css" rel="stylesheet"/>
            <link href="/resources/keyboard/syr/syr.css" rel="stylesheet"/>
            <script type="text/javascript" src="/resources/keyboard/syr/jquery.keyboard.js"/>
            <script type="text/javascript" src="/resources/keyboard/js/jquery.keyboard.extension-mobile.min.js"/>
            <script type="text/javascript" src="/resources/keyboard/js/jquery.keyboard.extension-navigation.min.js"/>
            <script type="text/javascript" src="/resources/keyboard/syr/jquery.keyboard.extension-autocomplete.js"/>
            <script type="text/javascript" src="/resources/keyboard/syr/keyboardSupport.js"/>
            <script type="text/javascript" src="/resources/keyboard/syr/syr.js"/>
            <script type="text/javascript" src="/resources/keyboard/layouts/ms-Greek.min.js"/>
            <script type="text/javascript" src="/resources/keyboard/layouts/ms-Russian.min.js"/>
            <script type="text/javascript" src="/resources/keyboard/layouts/ms-Arabic.min.js"/>
            <script type="text/javascript" src="/resources/keyboard/layouts/ms-Hebrew.min.js"/>
            <script type="text/javascript">
                <xsl:text disable-output-escaping="yes">
                    <![CDATA[
                $(document).ready(function () {
                $('[data-toggle="tooltip"]').tooltip({ container: 'body' })
                
                $('.keyboard').keyboard({
                openOn: null,
                stayOpen: false,
                alwaysOpen: false,
                autoAccept: true,
                usePreview: false,
                initialFocus: true,
                rtl : true,
                layout: 'syriac-phonetic',
                hidden: function(event, keyboard, el){
                //  keyboard.destroy();
                }
                });
                
                $('.keyboard-select').click(function () {
                var keyboardID = '#' + $(this).data("keyboard-id")
                var kb = $(keyboardID).getkeyboard();
                //var kb = $('#searchField').getkeyboard();
                // change layout based on link ID
                kb.options.layout = this.id
                // open keyboard if layout is different, or time from it last closing is &gt; 200 ms
                if (kb.last.layout !== kb.options.layout || (new Date().getTime() - kb.last.eventTime) < 200) {
                kb.reveal();
                }
                });
                //Change fonts
                $('.swap-font').on('click', function(){
                var selectedFont = $(this).data("font-id")
                $('.selectableFont').not('.syr').css('font-family', selectedFont);
                $("*:lang(syr)").css('font-family', selectedFont)
                });
                
                })]]>
                </xsl:text>
            </script>
        </head>
    </xsl:template>
    <xsl:template name="genericNav">
        <nav xmlns="http://www.w3.org/1999/xhtml" class="navbar navbar-default navbar-fixed-top" role="navigation">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                </button>
                <a class="navbar-brand banner-container" href="index.html"> 
                    <span class="syriaca-icon syriaca-syriaca banner-icon">
                        <span class="path1"/><span class="path2"/><span class="path3"/><span class="path4"/>
                    </span>
                    <span class="banner-text"><xsl:value-of select="$config/html:title[1]"/>T1</span>
                </a>
            </div>
            <div class="navbar-collapse collapse pull-right" id="navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <xsl:call-template name="syriacaSharedLinks"/>
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle lonely-caret" data-toggle="dropdown"> 
                            <span class="mobile-submenu">About</span>  <b class="caret"/>
                        </a>
                        <ul class="dropdown-menu pull-right">
                            <li>
                                <a href="/about-syriac.html">What is Syriac?</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/about-srophe.html">Project Overview</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/project-team.html">Project Team</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/project-partners.html">Project Partners</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/geo/index.html">
                                    <span class="icon-text">Gazetteer</span>
                                </a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="http://vu.edu/syriac">Support Our Work</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/contact-us.html">Contact Us</a>
                            </li>
                            <li role="presentation" class="divider"/>
                            <li>
                                <a href="/documentation/index.html">
                                    <span class="syriaca-icon syriaca-book icon-nav" style="color:red;"/>
                                    <span class="icon-text">Documentation</span>
                                </a>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <a href="search.html" class="nav-text">Advanced Search</a>
                    </li>
                    <li>
                        <div id="search-wrapper">
                            <form class="navbar-form navbar-right search-box" role="search" action="search.html" method="get">
                                <div class="form-group">
                                    <input type="text" class="form-control keyboard" placeholder="search" name="keyword" id="keywordNav"/>
                                    <xsl:call-template name="keyboard-select-menu">
                                        <xsl:with-param name="inputID" select="'keywordNav'"></xsl:with-param>
                                    </xsl:call-template>
                                    <button class="btn btn-default search-btn" id="searchbtn" type="submit" title="Search">
                                        <span class="glyphicon glyphicon-search"/>
                                    </button>                                    
                                </div>
                            </form>
                        </div>
                    </li>
                    <li>
                        <div class="btn-nav">
                            <button class="btn btn-default navbar-btn" id="font" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Select Font">
                                <span class="glyphicon glyphicon-font"/>
                            </button>  
                            <ul class="dropdown-menu dropdown-menu-right" id="swap-font">
                                <li>
                                    <a href="#" class="swap-font" id="DefaultSelect" data-font-id="EstrangeloEdessa">Default</a>
                                </li>
                                <li>
                                    <a href="#" class="swap-font" id="EstrangeloEdessaSelect" data-font-id="EstrangeloEdessa">Estrangelo Edessa</a>
                                </li>
                                <li>
                                    <a href="#" class="swap-font" id="EastSyriacAdiabeneSelect" data-font-id="EastSyriacAdiabene">East Syriac Adiabene</a>
                                </li>
                                <li>
                                    <a href="#" class="swap-font" id="SertoBatnanSelect" data-font-id="SertoBatnan">Serto Batnan</a>
                                </li>
                                <li>
                                    <a href="$app-root/documentation/wiki.html?wiki-page=/How-to-view-Syriac-script&amp;wiki-uri=https://github.com/srophe/syriaca-data/wiki">Help <span class="glyphicon glyphicon-question-sign"/>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </li>
                </ul>
            </div>
        </nav>
    </xsl:template>
    <xsl:template name="generickeyboardSelect">
        <span xmlns="http://www.w3.org/1999/xhtml" class="keyboard-menu">
            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Select Keyboard">
                &#160;<span class="syriaca-icon syriaca-keyboard">&#160; </span><span class="caret"/>
            </button>
            <ul class="dropdown-menu">
                <li><a href="#" class="keyboard-select" id="syriac-phonetic" data-keyboard-id="keywordNav">Syriac Phonetic</a></li>
                <li><a href="#" class="keyboard-select" id="syriac-standard" data-keyboard-id="keywordNav">Syriac Standard</a></li>
                <li> <a href="#" class="keyboard-select" id="ms-Arabic (101)" data-keyboard-id="keywordNav">Arabic Mod. Standard</a></li>
                <li><a href="#" class="keyboard-select" id="ms-Hebrew" data-keyboard-id="keywordNav">Hebrew</a></li>
                <li><a href="#" class="keyboard-select" id="ms-Russian" data-keyboard-id="keywordNav">Russian</a></li>
                <li><a href="#" class="keyboard-select" id="ms-Greek" data-keyboard-id="keywordNav">Greek</a></li>
                <li><a href="#" class="keyboard-select" id="qwerty" data-keyboard-id="keywordNav">English QWERTY</a></li>
            </ul>
        </span>
    </xsl:template>
    <xsl:template name="keyboard-select-menu">
        <xsl:param name="inputID"/>
        <xsl:if test="$config/descendant::*:keyboard-options/child::*">
            <span xmlns="http://www.w3.org/1999/xhtml" class="keyboard-menu">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Select Keyboard">
                    &#160;<span class="syriaca-icon syriaca-keyboard">&#160; </span><span class="caret"/>
                </button>
                <ul class="dropdown-menu">
                    <xsl:for-each select="$config/descendant::*:keyboard-options/*:option">
                        <li xmlns="http://www.w3.org/1999/xhtml">
                            <a href="#" class="keyboard-select" id="{@id}" data-keyboard-id="{$inputID}"><xsl:value-of select="."/></a>
                        </li>
                    </xsl:for-each>
                </ul>
            </span>
        </xsl:if>
    </xsl:template>
    <xsl:template name="syriacaSharedLinks">
        <xsl:if test="doc-available(concat($applicationPath,'/','templates/shared-links.html'))">
            <xsl:copy-of select="doc(concat($applicationPath,'/','templates/shared-links.html'))"/>
        </xsl:if>
    </xsl:template>
    
    <!--WS:NOTE I do not think this is working correctly: Copy all other HTML elements -->
   <!--
    <xsl:template match="html:*">
        <xsl:choose>
            <xsl:when test="element()">
                <xsl:element name="{name(.)}" namespace="http://www.w3.org/1999/xhtml">
                    <xsl:for-each select="@*">
                        <xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
                    </xsl:for-each>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    -->
    
</xsl:stylesheet>
