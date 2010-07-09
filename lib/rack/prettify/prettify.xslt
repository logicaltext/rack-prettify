<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" indent="yes" />
  <xsl:param name="indent-increment" select="'  '"/>

  <xsl:template name="newline">
    <xsl:text disable-output-escaping="yes">
</xsl:text>
  </xsl:template>

  <xsl:template match="comment() | processing-instruction()">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:copy />
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="indent" select="''"/>
    <!-- If the text of the preceding text sibling ends with whitespace,
         or this text begins with whitespace,
         output a newline. -->
    <xsl:if test="(normalize-space(
                    substring(preceding-sibling::*[1][text()],
                    string-length(preceding-sibling::*[1][text()]), 1))='') or
                  (normalize-space(substring(., 1, 1))='')">
      <xsl:call-template name="newline"/>
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="text()[normalize-space(.)='']"/>

  <xsl:template match="script">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="." disable-output-escaping="yes" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="indent" select="''"/>
    <!-- if the preceding node is a text node and doesn't end in whitespace,
         don't output a newline.

         ==

         unless the preceding node is a text node which doesn't end in whitespace,
         output a newline.
    -->
    <xsl:if test="not(
      (preceding-sibling::node()[1][self::text()]) and
      not(
        normalize-space(
          substring(
            preceding-sibling::node()[1][self::text()],
            string-length(preceding-sibling::node()[1][self::text()]),
            1
          )
        )=''
      ))">
      <xsl:call-template name="newline"/>
      <xsl:value-of select="$indent"/>
    </xsl:if>
      <xsl:choose>
       <xsl:when test="count(child::*) > 0">
        <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="*|text()">
           <xsl:with-param name="indent"
                           select="concat ($indent, $indent-increment)"/>
         </xsl:apply-templates>
         <xsl:call-template name="newline"/>
         <xsl:value-of select="$indent"/>
        </xsl:copy>
       </xsl:when>
       <xsl:otherwise>
        <xsl:copy-of select="."/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
