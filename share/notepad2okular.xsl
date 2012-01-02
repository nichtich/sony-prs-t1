<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  notepad2okular.xsl - transform Sony PRS note to Okular annotation
  
  apply this to 
      
    /media/READER/Sony_Reader/media/notepads/*.note 
    /media/READER/Sony_Reader/

  and copy the result to:

  $(kde4-config - -localprefix)/share/apps/okular/docdata/

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:note="http://www.sony.com/notepad" 
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="note svg">

    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:param name="author"/>
    <xsl:param name="created">1970-01-01T00:00:00</xsl:param>
    <xsl:param name="modified">1970-01-01T00:00:00</xsl:param>
    <xsl:param name="color">#ff0000</xsl:param>
    
    <xsl:variable name="width"  select="/note:notepad/note:drawing/@width"/>
    <xsl:variable name="height" select="/note:notepad/note:drawing/@height"/>

    <xsl:template match="/note:notepad">
        <xsl:apply-templates select="note:drawing/note:page[1]"/>
    </xsl:template>

    <xsl:template match="note:page">
		<annotationList>
			<annotation type="6">
				<base creationDate="{$created}" modifyDate="{$modified}" 
					author="{$author}" color="{$color}">
					<!-- uniqueName="okular-2-1" -->

					<boundary l="0" r="1" b="1" t="0"/> <!-- full page (TODO) -->

					<!-- TODO: I am not sure about the attributes of this: -->
					<penStyle width="2" ycr="0" style="1" spaces="0" marks="3" xcr="0"/>
				</base>
				<ink>
					<xsl:apply-templates select="svg:svg/svg:polyline"/>
				</ink>
			</annotation>
		</annotationList>
    </xsl:template>

    <!-- all lines have the same attributes so we only process points -->
    <xsl:template match="svg:polyline">
        <path>
            <xsl:call-template name="points">
                <xsl:with-param name="list" select="@points"/>
            </xsl:call-template>
        </path>
    </xsl:template>
    
    <!-- transform a list of points -->
    <xsl:template name="points">
        <xsl:param name="list"/>

        <xsl:variable name="fulllist" select="concat($list,' ')"/>
        <xsl:variable name="px" select="substring-before($fulllist,',')"/>
        <xsl:variable name="second" select="substring-after($fulllist,',')"/>
        <xsl:variable name="py" select="substring-before($second,' ')"/>
        <xsl:variable name="rest" select="substring-after($second,' ')"/>

		<!-- TODO: all points seem to be shifted, are there margins?! -->
        <point x="{$px div $width}" y="{$py div $height}" />

        <xsl:if test="normalize-space($rest)">
            <xsl:call-template name="points">
                <xsl:with-param name="list" select="$rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
