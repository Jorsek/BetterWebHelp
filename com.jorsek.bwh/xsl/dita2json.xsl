<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	
	<xsl:template name="substring-before-last">
		<xsl:param name="input" />
		<xsl:param name="substr" />
		<xsl:if test="$substr and contains($input, $substr)">
			<xsl:variable name="temp" select="substring-after($input, $substr)" />
			<xsl:value-of select="substring-before($input, $substr)" />
			<xsl:if test="contains($temp, $substr)">
				<xsl:value-of select="$substr" />
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="input" select="$temp" />
					<xsl:with-param name="substr" select="$substr" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/">
		[
		<xsl:apply-templates select="*"/>
		]
	</xsl:template>
	
	<xsl:template match="*[contains(@class, ' map/map ' )]">
		<xsl:for-each select="//topicref">
			<xsl:variable name="urisubstring">
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="input" select="@href" />
					<xsl:with-param name="substr" select="'.'" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="uri1">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$urisubstring"/>
					<xsl:with-param name="remove" select="'&quot;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="uri">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$uri1"/>
					<xsl:with-param name="remove" select="'&#92;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="title1">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="normalize-space(document(@href)//title)"/>
					<xsl:with-param name="remove" select="'&quot;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="title">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$title1"/>
					<xsl:with-param name="remove" select="'&#92;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="shortdesc1">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="normalize-space(document(@href)//shortdesc)"/>
					<xsl:with-param name="remove" select="'&quot;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="shortdesc">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$shortdesc1"/>
					<xsl:with-param name="remove" select="'&#92;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="body1">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="normalize-space(document(@href)//*[contains(@class, ' topic/body ' )])"/>
					<xsl:with-param name="remove" select="'&quot;'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="body">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$body1"/>
					<xsl:with-param name="remove" select="'&#92;'"/>
				</xsl:call-template>
			</xsl:variable>
			{
			"<xsl:text>URI</xsl:text>" : "<xsl:value-of select="$uri"/>.html",
			"<xsl:text>Title</xsl:text>" : "<xsl:value-of select="$title"/>",
			"<xsl:text>Shortdesc</xsl:text>" : "<xsl:value-of select="$shortdesc"/>",
			"<xsl:text>Body</xsl:text>" : "<xsl:value-of select="$body"/>"
			},
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="string-replace-all">
		<xsl:param name="text" />
		<xsl:param name="remove"/>
		<xsl:choose>
			<xsl:when test="contains($text, $remove)">
				<xsl:value-of select="substring-before($text,$remove)" />
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-after($text,$remove)" />
					<xsl:with-param name="remove" select="$remove" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>