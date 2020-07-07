<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:codhr="http://codhr.tamu.edu/#schema" exclude-result-prefixes="codhr" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="codhr:list/codhr:item">
        <xsl:result-document href="taxonomyIndex.xml">
            <xsl:variable name="dir" select="@dir"/>
            <taxonomy>
                <listURI ref="http://syriaca.org/keyword/ethnicity">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/ethnicity']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/fields-of-study">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/fields-of-study']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/languages">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/languages']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/mental-states">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/mental-states']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/occupations">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/occupations']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/sanctity">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/sanctity']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/socioeconomic-status">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/socioeconomic-status']">
                        <uri>
                            <xsl:apply-templates select="./@active"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/event-relationships">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/event-relationships']">
                        <uri>
                            <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/qualifier-relationships">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/qualifier-relationships']">
                        <uri>
                            <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                        </uri>
                    </xsl:for-each>
                </listURI>
                <listURI ref="http://syriaca.org/keyword/relationships">
                    <listURI ref="http://syriaca.org/keyword/clerical-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/clerical-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/epistolary-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/epistolary-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/family-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/family-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/general-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/general-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/intellectual-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/intellectual-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/legal-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/legal-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/military-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/military-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/monastic-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/monastic-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/personal-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/personal-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/professional-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/professional-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/religious-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/religious-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                    <listURI ref="http://syriaca.org/keyword/slavery-relationships">
                        <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//listRelation/relation[@passive = 'http://syriaca.org/keyword/slavery-relationships']">
                            <uri>
                                <xsl:if test="ancestor::entryFree/idno/@ana = 'mutual' or 'reciprocal'">
                                    <xsl:attribute name="ana" select="ancestor::entryFree/idno/@ana"/>
                                </xsl:if>
                                <xsl:apply-templates select="ancestor::entryFree/idno[@type = 'SPEAR']"/>
                            </uri>
                        </xsl:for-each>
                    </listURI>
                </listURI>
                <listURI type="taxonomyAllURIs">
                    <xsl:for-each select="collection(iri-to-uri(concat($dir, '?select=*.xml')))/TEI//entryFree//idno[contains(., 'syriaca.org/keyword')]">
                        <uri>
                            <xsl:apply-templates select="."/>
                        </uri>
                    </xsl:for-each>
                </listURI>
            </taxonomy>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>