<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  notepad2svg.xsl - extract SVG notes from Sony PRS T1 reader data 
  
  apply this to /media/READER/Sony_Reader/media/notepads/*.note files
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:note="http://www.sony.com/notepad" 
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:xml="http://www.w3.org/XML/1998/namespace">

	<xsl:template match="/note:notepad">
		<xsl:apply-templates select="//note:page[1]"/>
	</xsl:template>

	<xsl:template match="note:page">
		<xsl:copy-of select="svg:svg"/>
	</xsl:template>
	
</xsl:stylesheet>
