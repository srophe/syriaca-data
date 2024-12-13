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
    <xsl:template name="leafletMap">
        <xsl:param name="nodes"/>
        <xsl:variable name="coords" select="$nodes/descendant::t:geo"/>
        <xsl:variable name="geojson">
            <xsl:call-template name="geojson"><xsl:with-param name="nodes" select="$nodes"/></xsl:call-template>    
        </xsl:variable>
        <div id="map-data" style="margin-bottom:3em;">
            <!-- Leaflet javascript -->
            <script type="text/javascript" src="/resources/leaflet/leaflet.js"/>
            <div id="map"/>    
            <xsl:if test="count($coords) &gt; 0">                
                <div class="hint map pull-right small">
                    * This map displays <xsl:value-of select="count($coords)"/> records. Only places with coordinates are displayed. 
                    <button class="btn btn-default btn-sm" data-toggle="modal" data-target="#map-selection" id="mapFAQ">See why?</button>
                </div>
            </xsl:if>
            <script type="text/javascript">
                <xsl:text disable-output-escaping="yes"><![CDATA[
                var terrain = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}');                
                var streets = L.tileLayer(
                    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
                    {attribution: "OpenStreetMap"});                                
                var imperium = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {maxZoom: 10});
                var placesgeo = ]]></xsl:text><xsl:sequence select="$geojson"/><xsl:text disable-output-escaping="yes"> <![CDATA[                                           
                var geojson = L.geoJson(placesgeo, {onEachFeature: function (feature, layer){
                            var typeText = feature.properties.type
                            var popupContent = 
                                "<a href='" + feature.properties.uri + "' class='map-pop-title'>" +
                                feature.properties.name + "</a>" + (feature.properties.type ? "Type: " + typeText : "") +
                                (feature.properties.desc ? "<span class='map-pop-desc'>"+ feature.properties.desc +"</span>" : "");
                                layer.bindPopup(popupContent);
                                }
                            })
                var map = L.map('map').fitBounds(geojson.getBounds(),{maxZoom: 5});     
                terrain.addTo(map);            
                L.control.layers({
                        "Terrain (default)": terrain,
                        "Streets": streets }).addTo(map);
            geojson.addTo(map);   
                ]]></xsl:text>
            </script>
            <div>
                <div class="modal fade" id="map-selection" tabindex="-1" role="dialog" aria-labelledby="map-selectionLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal">
                                    <span aria-hidden="true"> x </span>
                                    <span class="sr-only">Close</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <div id="popup" style="border:none; margin:0;padding:0;margin-top:-2em;"/>
                            </div>
                            <div class="modal-footer">
                                <a class="btn" href="/documentation/faq.html" aria-hidden="true">See all FAQs</a>
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <script type="text/javascript">
                <![CDATA[
                $('#mapFAQ').click(function(){
                    $('#popup').load( '/documentation/faq.html #map-selection',function(result){
                        $('#map-selection').modal({show:true});
                    });
                 });
                 ]]>
            </script>
        </div> 
    </xsl:template>
    <xsl:template name="geojson">
        <xsl:param name="nodes"/>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="string(/*/@id)">
                    <xsl:value-of select="string(/*/@id)"/>
                </xsl:when>
                <xsl:when test="$nodes/descendant::t:publicationStmt/t:idno[@type='URI'][starts-with(.,$base-uri)]">
                    <xsl:value-of select="replace(replace($nodes/descendant::t:publicationStmt[1]/t:idno[@type='URI'][starts-with(.,$base-uri)][1],'/tei',''),'/source','')"/>
                </xsl:when>
                <xsl:when test="$nodes/descendant::t:publicationStmt/t:idno[@type='URI']">
                    <xsl:value-of select="replace(replace($nodes/descendant::t:publicationStmt[1]/t:idno[@type='URI'][1],'/tei',''),'/source','')"/>
                </xsl:when>
                <xsl:when test="$nodes/descendant::t:idno[@type='URI'][starts-with(.,$base-uri)]">
                    <xsl:value-of select="replace(replace($nodes/descendant::t:idno[@type='URI'][starts-with(.,$base-uri)][1],'/tei',''),'/source','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($base-uri,'/0000')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:apply-templates select="normalize-space(string-join($nodes/descendant-or-self::t:titleStmt/t:title[1],''))"/>
        </xsl:variable>
        <xsl:variable name="desc">
            <xsl:choose>
                <xsl:when test="$nodes/descendant::t:desc[1]/t:quote">
                    <xsl:value-of select="normalize-space(string-join($nodes/descendant::t:desc[1]/t:quote))"/>
                </xsl:when>
                <xsl:when test="$nodes/descendant::t:desc">
                    <xsl:value-of select="normalize-space(string-join($nodes/descendant::t:desc[1]))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="$nodes/descendant::t:relationType != ''">
                    <xsl:value-of select="normalize-space(string-join($nodes/descendant::t:relationType))"/>
                </xsl:when>
                <xsl:when test="$nodes/descendant::t:place/@type">
                    <xsl:value-of select="$nodes/descendant::t:place/@type"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="coords">
            <xsl:choose>
                <xsl:when test="$nodes/descendant::t:location[@subtype = 'preferred']">
                    <xsl:value-of select="$nodes/descendant::t:location[@subtype = 'preferred']/t:geo"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$nodes/descendant::t:geo[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="xml">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <string key="type">FeatureCollection</string>
                <array key="features">
                    <xsl:for-each select="$coords">
                        <map xmlns="http://www.w3.org/2005/xpath-functions">
                            <string key="type">Feature</string>
                            <map key="properties">
                                <string key="name"><xsl:value-of select="$title"/></string>
                                <xsl:if test="$desc != ''">
                                    <string key="desc" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$desc"/></string>    
                                </xsl:if>
                                <xsl:if test="$type != ''">
                                    <string key="type" xmlns="http://www.w3.org/2005/xpath-functions"><xsl:value-of select="$type"/></string>    
                                </xsl:if>
                            </map>
                            <map key="geometry">
                                <string key="type">Point</string>
                                <array key="coordinates">
                                    <number><xsl:value-of select="tokenize($coords,' ')[2]"/></number>
                                    <number><xsl:value-of select="tokenize($coords,' ')[1]"/></number>
                                </array>
                            </map>
                        </map>
                    </xsl:for-each>
                </array>
            </map>
        </xsl:variable>
        <!-- OUTPUT -->
        <xsl:value-of select="xml-to-json($xml, map { 'indent' : true() })"/>
    </xsl:template>
    
</xsl:stylesheet>
