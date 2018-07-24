<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:codhr="http://codhr.tamu.edu/#schema" exclude-result-prefixes="codhr"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="clerical" select="'http://syriaca.org/keyword/clerical-relationships'"/>
    <xsl:variable name="epistolary" select="'http://syriaca.org/keyword/epistolary-relationships'"/>
    <xsl:variable name="family" select="'http://syriaca.org/keyword/family-relationships'"/>
    <xsl:variable name="general" select="'http://syriaca.org/keyword/general-relationships'"/>
    <xsl:variable name="intellectual"
        select="'http://syriaca.org/keyword/intellectual-relationships'"/>
    <xsl:variable name="legal" select="'http://syriaca.org/keyword/legal-relationships'"/>
    <xsl:variable name="military" select="'http://syriaca.org/keyword/military-relationships'"/>
    <xsl:variable name="monastic" select="'http://syriaca.org/keyword/monastic-relationships'"/>
    <xsl:variable name="personal" select="'http://syriaca.org/keyword/personal-relationships'"/>
    <xsl:variable name="professional"
        select="'http://syriaca.org/keyword/professional-relationships'"/>
    <xsl:variable name="religious" select="'http://syriaca.org/keyword/religious-relationships'"/>
    <xsl:variable name="slavery" select="'http://syriaca.org/keyword/slavery-relationships'"/>





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
                    <listURI ref="{$clerical}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $clerical]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$epistolary}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $epistolary]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$family}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $family]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$general}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $general]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$intellectual}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $intellectual]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$legal}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $legal]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$military}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $military]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$monastic}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $monastic]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$personal}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $personal]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$professional}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $professional]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$religious}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $religious]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>

                    <listURI ref="{$slavery}">
                        <xsl:for-each
                            select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = $slavery]">
                            <uri>
                                <xsl:apply-templates select="ancestor::entryFree/idno[not(@type='URI')]"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                </listURI>
            </taxonomy>
        </xsl:result-document>
    </xsl:template>










    <!--<xsl:template match="/">
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
