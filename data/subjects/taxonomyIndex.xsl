<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:codhr="http://codhr.tamu.edu/#schema" exclude-result-prefixes="codhr"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="dir" select="@dir"/>
    <!--<xsl:variable name="clerical" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/clerical-relationships'])"/>
    <xsl:variable name="epistolary" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/epistolary-relationships'])"/>
    <xsl:variable name="family" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/family-relationships'])"/>
    <xsl:variable name="general" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/general-relationships'])"/>
    <xsl:variable name="intellectual"
        select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/intellectual-relationships'])"/>
    <xsl:variable name="legal" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/legal-relationships'])"/>
    <xsl:variable name="military" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/military-relationships'])"/>
    <xsl:variable name="monastic" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/monastic-relationships'])"/>
    <xsl:variable name="personal" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/personal-relationships'])"/>
    <xsl:variable name="professional"
        select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/professional-relationships'])"/>
    <xsl:variable name="religious" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/religious-relationships'])"/>
    <xsl:variable name="slavery" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/slavery-relationships'])"/>
    <xsl:variable name="ethnicity" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/ethnicity'])"/>
    <xsl:variable name="eventRelationships" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/event-relationships'])"/>
    <xsl:variable name="fieldsOfStudy" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/fields-of-study'])"/>
    <xsl:variable name="languages" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/languages'])"/>
    <xsl:variable name="mentalStates" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/mental-states'])"/>
    <xsl:variable name="occupations" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/occupations'])"/>
    <xsl:variable name="sanctity" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/sanctity'])"/>
    <xsl:variable name="qualifierRelationships" select="distinct-values(collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/qualifier-relationships'])"/>
    <xsl:variable name="socecStatus" select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/socioeconomic-status']/@active"/>-->
    
    






    <xsl:template match="codhr:list/codhr:item">
        <xsl:result-document href="taxonomyIndex.xml">
            <xsl:variable name="dir" select="@dir"/>
            <taxonomy>
                <listURI ref="http://syriaca.org/keyword/socioeconomic-status">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/socioeconomic-status']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/ethnicity">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/ethnicity']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/event-relationships">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/event-relationships']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/fields-of-study">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/fields-of-study']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/languages">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/languages']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/mental-states">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/mental-states']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/occupations">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/occupations']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/sanctity">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/sanctity']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/keyword/qualifier-relationships">
                    <xsl:for-each
                        select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/qualifier-relationships']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                
                <listURI ref="http://syriaca.org/relationships">
                    <listURI ref="http://syriaca.org/keyword/clerical-relationship">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/clerical-relationship']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/epistolary-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/epistolary-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/family-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/family-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/> 
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/general-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/general-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/intellectual-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/intellectual-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/legal-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/legal-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/military-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/military-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/monastic-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/monastic-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/personal-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/personal-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/professional-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/professional-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/religious-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/religious-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    
                    <listURI ref="http://syriaca.org/keyword/slavery-relationships">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/slavery-relationships']">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                </listURI>
            </taxonomy>
        </xsl:result-document>
    </xsl:template>




    <!--





    <xsl:template match="/">
        <listURI ref="relationships">
            <xsl:for-each select="//listRelation/relation[@passive = $clerical]">
                <listURI ref="{$clerical}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $epistolary]">
                <listURI ref="{$epistolary}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $family]">
                <listURI ref="{$family}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $general]">
                <listURI ref="{$general}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $intellectual]">
                <listURI ref="{$intellectual}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $legal]">
                <listURI ref="{$legal}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $military]">
                <listURI ref="{$military}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $monastic]">
                <listURI ref="{$monastic}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $personal]">
                <listURI ref="{$personal}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $professional]">
                <listURI ref="{$professional}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $religious]">
                <listURI ref="{$religious}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
            <xsl:for-each select="//listRelation/relation[@passive = $slavery]">
                <listURI ref="{$slavery}">
                    <uri>
                        <xsl:apply-templates select="./@active"/>
                    </uri>
                </listURI>
            </xsl:for-each>
        </listURI>
    </xsl:template>-->







</xsl:stylesheet>
