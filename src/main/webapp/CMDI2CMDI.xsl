<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output omit-xml-declaration="yes" indent="yes"/>
 <xsl:strip-space elements="*"/>

 <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
 </xsl:template>

 <xsl:template match="@*|node()" priority="5">
  <xsl:if test="normalize-space(.) != '' or ./@* != ''">
    <xsl:copy>
       <xsl:copy-of select = "@*"/>
       <xsl:apply-templates/>
    </xsl:copy>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
