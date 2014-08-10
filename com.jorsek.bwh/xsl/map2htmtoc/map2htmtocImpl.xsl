<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                exclude-result-prefixes="dita-ot ditamsg"
                >

<!-- map2htmltoc.xsl   main stylesheet
     Convert DITA map to a simple HTML table-of-contents view.
     Input = one DITA map file
     Output = one HTML file for viewing/checking by the author.

     Options:
        OUTEXT  = XHTML output extension (default is '.html')
        WORKDIR = The working directory that contains the document being transformed.
                   Needed as a directory prefix for the @href "document()" function calls.
                   Default is './'
-->

<!-- Include error message template -->
<xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-textonly.xsl"/>

<xsl:output method="html" indent="no" encoding="UTF-8"/>
<xsl:output method="html" indent="yes" name="html"/>

<!-- Set the prefix for error message numbers -->
<xsl:variable name="msgprefix">DOTX</xsl:variable>

<!-- *************************** Command line parameters *********************** -->
<xsl:param name="OUTEXT" select="'.html'"/><!-- "htm" and "html" are valid values -->
<xsl:param name="WORKDIR" select="'./'"/>
<xsl:param name="DITAEXT" select="'.xml'"/>
<xsl:param name="FILEREF" select="'file://'"/>
<xsl:param name="contenttarget" select="'contentwin'"/>
<xsl:param name="CSS"/>
<xsl:param name="CSSPATH"/>
<xsl:param name="dita-css" select="'commonltr.css'"/> <!-- left to right languages -->
<xsl:param name="bidi-dita-css" select="'commonrtl.css'"/> <!-- bidirectional languages -->
<xsl:param name="OUTFILE"/>
<xsl:param name="OUTPUTDIR"/>
<xsl:param name="OUTPUTCLASS"/>   <!-- class to put on body element. -->
<!-- the path back to the project. Used for c.gif, delta.gif, css to allow user's to have
  these files in 1 location. -->
<xsl:param name="PATH2PROJ">
  <xsl:apply-templates select="/processing-instruction('path2project-uri')[1]" mode="get-path2project"/>
</xsl:param>
<xsl:param name="genDefMeta" select="'no'"/>
<xsl:param name="YEAR" select="'2005'"/>
<!-- Define a newline character -->
<xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>

<!-- *********************************************************************************
     Setup the HTML wrapper for the table of contents
     ********************************************************************************* -->
  <xsl:template match="/">
    <xsl:call-template name="generate-toc"/>
  </xsl:template>
<!--  -->
<xsl:template name="generate-toc">
  <html><xsl:value-of select="$newline"/>
  <head><xsl:value-of select="$newline"/>
    <!-- initial meta information -->
    <xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
    <xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
    <xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
    <xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
  	<xsl:call-template name="viewport"/>
    <!--<xsl:call-template name="generateCssLinks"/>  <!-\- Generate links to CSS files -\->-->
    <xsl:call-template name="gen-user-head" />    <!-- include user's XSL HEAD processing here -->
    <xsl:call-template name="gen-user-scripts" /> <!-- include user's XSL javascripts here -->
    <xsl:call-template name="gen-user-styles" />  <!-- include user's XSL style element and content here -->
  	<xsl:call-template name="mobileapp-meta"/>    <!-- include the meta info to make it a mobile web app on homescreens -->
  	<xsl:call-template name="frameless-styles"/>  <!-- include the stylesheet for the frameless content -->
  	<xsl:call-template name="content-scripts"/>   <!-- include the scripts for ajax content loading and nav panel functionality -->
  	<xsl:call-template name="generateMapTitle"/>  <!-- Generate the <title> element -->
  </head><xsl:value-of select="$newline"/>
  	
		<body>
			<xsl:if test="string-length($OUTPUTCLASS) &gt; 0">
				<xsl:attribute name="class">
					<xsl:value-of select="$OUTPUTCLASS"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$newline"/>
			<div id="container">
<!-- heading to be filled in using javascript upon page load so that user can add custom headings-->
				<div id="heading">//</div>
				<xsl:call-template name="search-bar"/>
				<div id="main">
					<div id="web-help">
<!-- web-help-c1 contains the table of contents information -->
						<div id="web-help-c1">
							<xsl:apply-templates/>
						</div>
<!-- web-help-c2 will contain the content information loaded through ajax -->
						<div id="web-help-c2">
							//
						</div>
					</div>
				</div>
				<div id="footer">//</div>
<!-- the following divs are to build the draggable handle on mobile -->
				<div id="drag-container" class="dragdealer">
					<div id="drag-handle" class="handle">
						<div id="drag-button">
<!-- to be styled with CSS to make them look like buttons -->
							<div id="drag-icon-bg"></div>
							<div id="drag-icon"></div>
						</div>
					</div>
				</div>
			</div>
<!-- initialize the dragdealer draggable handle and set the default 
	opacity and clickability of the content if not on mobile -->
			<script type="text/javascript">
				var dd = new Dragdealer('drag-container',
				{horizontal: true, vertical: true, tapping: false, loose: true, steps: 2, y: 0, x: 1,
				animationCallback: function(x,y) {slideNav(x,y)}, callback: function(x,y) {fadeHandle(x,y)}});
				
				if ($( window ).width() <xsl:value-of select="'&gt;'" disable-output-escaping="yes"/> 600) {
					dd.setValue(0,1,snap=true);
					
					document.getElementById('web-help-c2').style.opacity = 1.0;
					document.getElementById('heading').style.opacity = 1.0;
					document.getElementById('web-help-c2').style.pointerEvents = 'auto';
					document.getElementById('heading').style.pointerEvents = 'auto';
				};
			</script>
		</body><xsl:value-of select="$newline"/>
  </html>
</xsl:template>

<xsl:template name="content-scripts">
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js">//</script>
	<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.11.0/jquery-ui.min.js">//</script>
	<script type="text/javascript" src="scripts/typeahead.bundle.js">//</script>
	<script type="text/javascript" src="scripts/queryString.js">//</script>
	<script type="text/javascript" src="scripts/dragdealer.js">//</script>
	<script type="text/javascript" src="scripts/lunr.js">//</script>
	<script type="text/javascript" src="scripts/lunrScripts.js">//</script>
	<script type="text/javascript" src="scripts/loadContent.js">//</script>
</xsl:template>

<xsl:template name="mobileapp-meta">
	<meta name="mobile-web-app-capable" content="yes"/>
	<meta name="apple-mobile-web-app-capable" content="yes"/>
	<link rel="icon" sizes="196x196" href="help-icon.png"/>
	<link rel="apple-touch-icon" sizes="196x196" href="help-icon.png"/>
</xsl:template>

<xsl:template name="viewport">
	<meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" name='viewport' />
	<meta name="viewport" content="width=device-width, minimal-ui" />
</xsl:template>

<xsl:template name="frameless-styles">
	<link rel="stylesheet" type="text/css" href="scripts/frameless.css" />
	<link rel="stylesheet" type="text/css" href="scripts/content-styling.css" />
	<link rel="stylesheet" type="text/css" href="scripts/user-fonts.css" />
	<link rel="stylesheet" type="text/css" href="scripts/user-styling.css" />
</xsl:template>

<xsl:template name="search-bar">
	<div id="search-bar">
		<form name="search-form" id="search-form">
			<input class="clearable typeahead" type="text" name="q" id="q" placeholder="Search..." />
			<input type="submit" id="search-button" value="Go!"/>
		</form>
	</div>
</xsl:template>

<xsl:template name="generateCharset">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><xsl:value-of select="$newline"/>
</xsl:template>

<!-- If there is no copyright in the document, make the standard one -->
<xsl:template name="generateDefaultCopyright">
  <xsl:if test="not(//*[contains(@class,' topic/copyright ')])">
    <meta name="copyright">
      <xsl:attribute name="content">
        <xsl:text>(C) </xsl:text>
        <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'Copyright'"/>
        </xsl:call-template>
        <xsl:text> </xsl:text><xsl:value-of select="$YEAR"/>
      </xsl:attribute>
    </meta>
    <xsl:value-of select="$newline"/>
    <meta name="DC.rights.owner">
      <xsl:attribute name="content">
        <xsl:text>(C) </xsl:text>
        <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'Copyright'"/>
        </xsl:call-template>
        <xsl:text> </xsl:text><xsl:value-of select="$YEAR"/>
      </xsl:attribute>
    </meta>
    <xsl:value-of select="$newline"/>
  </xsl:if>
</xsl:template>

<xsl:template name="generateDefaultMeta">
  <xsl:if test="$genDefMeta='yes'">
    <meta name="security" content="public" /><xsl:value-of select="$newline"/>
    <meta name="Robots" content="index,follow" /><xsl:value-of select="$newline"/>
    <xsl:text disable-output-escaping="yes">&lt;meta http-equiv="PICS-Label" content='(PICS-1.1 "http://www.icra.org/ratingsv02.html" l gen true r (cz 1 lz 1 nz 1 oz 1 vz 1) "http://www.rsac.org/ratingsv01.html" l gen true r (n 0 s 0 v 0 l 0) "http://www.classify.org/safesurf/" l gen true r (SS~~000 1))' /></xsl:text>
    <xsl:value-of select="$newline"/>
  </xsl:if>
</xsl:template>

<xsl:template name="copyright">
  
</xsl:template>
<!-- *********************************************************************************
     If processing only a single map, setup the HTML wrapper and output the contents.
     Otherwise, just process the contents.
     ********************************************************************************* -->
<!-- Deprecated: use "toc" mode instead -->
<!-- This is active -->
<xsl:template match="/*[contains(@class, ' map/map ')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:if test="contains(@class, ' bookmap/bookmap ' ) and //*[contains(@class, ' bookmap/preface ' )]/*">
  	<xsl:call-template name="bookmap-preface"/>
  </xsl:if>
  <xsl:if test=".//*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
    <ul class="web-help-nav"><xsl:value-of select="$newline"/>

      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc">
        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
      </xsl:apply-templates>
    </ul><xsl:value-of select="$newline"/>
  </xsl:if>
</xsl:template>

<xsl:template name="bookmap-preface">
	<xsl:variable name="preface.file" select="concat($OUTPUTDIR,'/preface.html')"/>
	<xsl:result-document href="{$preface.file}" format="html">
		<xsl:call-template name="bookmap-preface-content"/>
	</xsl:result-document>
</xsl:template>

<xsl:template name="bookmap-preface-content">
	<xsl:variable name="preface.root" select="doc(concat($WORKDIR,(//*[contains(@class, ' bookmap/preface ' )]/*/@href)[1]))"/>
	<html>
		<head/>
		<body>
			<h1><xsl:value-of select="$preface.root//*[contains(@class, ' topic/title ' )]/text()"/></h1>
			<div class="body">
				<p class="shortdesc"><xsl:value-of select="$preface.root//*[contains(@class, ' topic/shortdesc ' )]/text()"/></p>
				<xsl:for-each select="$preface.root//*[contains(@class, ' topic/p ')]">
					<p class="p"><xsl:value-of select="./text()"/></p>
				</xsl:for-each>
			</div>
			<ul class="preface-topic-grid">
				<xsl:call-template name="bookmap-topic-grid"/>
			</ul>
		</body>
	</html>
</xsl:template>

<xsl:template name="bookmap-topic-grid">
		<xsl:for-each select="/*[contains(@class, ' bookmap/bookmap ' )]/*[contains(@class, ' bookmap/chapter ' )]">
			<li class="preface-topic">
				<strong><a class=" ajaxLink ">
					<xsl:attribute name="href">
						<xsl:call-template name="replace-extension">
							<xsl:with-param name="filename" select="@href"/>
							<xsl:with-param name="extension" select="$OUTEXT"/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:value-of select="./*[contains(@class, ' map/topicmeta ' )]/*[contains(@class, ' topic/navtitle ' )]"/>
				</a></strong><br/>
				<xsl:if test="./@href">
					<p><xsl:value-of select="doc(concat($WORKDIR,data(./@href)))//*[contains(@class, ' topic/shortdesc ' )]"/></p>
				</xsl:if>
			</li>
		</xsl:for-each>
</xsl:template>

<xsl:template name="generateMapTitle">
  <!-- Title processing - special handling for short descriptions -->
  <xsl:if test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')] or /*[contains(@class,' map/map ')]/@title">
  <title>
    <xsl:call-template name="gen-user-panel-title-pfx"/> <!-- hook for a user-XSL title prefix -->
    <xsl:choose>
      <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]">
        <xsl:value-of select="normalize-space(/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')])"/>
      </xsl:when>
      <xsl:when test="/*[contains(@class,' map/map ')]/@title">
        <xsl:value-of select="/*[contains(@class,' map/map ')]/@title"/>
      </xsl:when>
    </xsl:choose>
  </title><xsl:value-of select="$newline"/>
  </xsl:if>
</xsl:template>

<xsl:template name="gen-user-panel-title-pfx">
  <xsl:apply-templates select="." mode="gen-user-panel-title-pfx"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-panel-title-pfx">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed immediately after TITLE tag, in the title -->
</xsl:template>

<!-- *********************************************************************************
     Output each topic as an <li> with an A-link. Each item takes 2 values:
     - A title. If a navtitle is specified on <topicref>, use that.
       Otherwise try to open the file and retrieve the title. First look for a navigation title in the topic,
       followed by the main topic title. Last, try to use <linktext> specified in the map.
       Failing that, use *** and issue a message.
     - An HREF is optional. If none is specified, this will generate a wrapper.
       Include the HREF if specified.
     - Ignore if TOC=no.

     If this topicref has any child topicref's that will be part of the navigation,
     output a <ul> around them and process the contents.
     ********************************************************************************* -->
<!-- Deprecated: use "toc" mode instead -->
<!-- See the topicref template in map2htmlImpl.xsl for the active template ("toc" mode) -->
<xsl:template match="*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:variable name="title">
    <xsl:apply-templates select="." mode="get-navtitle"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$title and $title!=''">
      <li>
        <xsl:choose>
          <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
          <xsl:when test="@href and not(@href='')">
            <xsl:element name="a">
            	<xsl:attribute name="class">
            		<xsl:choose>
            			<xsl:when test="(@class)">
            				<xsl:value-of select="concat(@class,' ajaxLink')"/>
            			</xsl:when>
            			<xsl:otherwise>
            				<xsl:value-of select="'ajaxLink'"/>
            			</xsl:otherwise>
            		</xsl:choose>
            	</xsl:attribute>
	              <xsl:attribute name="href">
	                <xsl:choose>        <!-- What if targeting a nested topic? Need to keep the ID? -->
	                  <xsl:when test="@copy-to and not(contains(@chunk, 'to-content')) and 
	                    (not(@format) or @format = 'dita' or @format='ditamap' ) ">
	                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
	                    <xsl:call-template name="replace-extension">
	                      <xsl:with-param name="filename" select="@copy-to"/>
	                      <xsl:with-param name="extension" select="$OUTEXT"/>
	                    </xsl:call-template>
	                    <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
	                      <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
	                    </xsl:if>
	                  </xsl:when>
	                  <xsl:when test="not(@scope = 'external') and (not(@format) or @format = 'dita' or @format='ditamap')">
	                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
	                    <xsl:call-template name="replace-extension">
	                      <xsl:with-param name="filename" select="@href"/>
	                      <xsl:with-param name="extension" select="$OUTEXT"/>
	                    </xsl:call-template>
	                  </xsl:when>
	                  <xsl:otherwise>  <!-- If non-DITA, keep the href as-is -->
	                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
	                    <xsl:value-of select="@href"/>
	                  </xsl:otherwise>
	                </xsl:choose>
              	</xsl:attribute>
              <xsl:if test="@scope='external' or @type='external' or ((@format='PDF' or @format='pdf') and not(@scope='local'))">
                <xsl:attribute name="target">_blank</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$title"/>
            </xsl:element>
          </xsl:when>
          
          <xsl:otherwise>
            <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>
        
        <!-- If there are any children that should be in the TOC, process them -->
        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))][not(@processing-role='resource-only')]">
          <xsl:value-of select="$newline"/><ul><xsl:value-of select="$newline"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
              <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
            </xsl:apply-templates>
          </ul><xsl:value-of select="$newline"/>
        </xsl:if>
      </li><xsl:value-of select="$newline"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- if it is an empty topicref -->
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- If toc=no, but a child has toc=yes, that child should bubble up to the top -->
<!-- Deprecated: use "toc" mode instead -->
<!-- See the topicref template in map2htmlImpl.xsl for the active template ("toc" mode) -->
<xsl:template match="*[contains(@class, ' map/topicref ')][@toc='no'][not(@processing-role='resource-only')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
  </xsl:apply-templates>
</xsl:template>

<!-- Deprecating the named template in favor of the mode template. -->
<xsl:template name="navtitle">
  <xsl:apply-templates select="." mode="get-navtitle"/>
</xsl:template>
<xsl:template match="*" mode="get-navtitle">
  <xsl:variable name="WORKDIR">
    <xsl:apply-templates select="/processing-instruction('workdir-uri')[1]" mode="get-work-dir"/>
  </xsl:variable>
  <xsl:choose>

    <!-- If navtitle is specified, use it (!?but it should only be used when locktitle=yes is specifed?!) -->
    <xsl:when test="*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]">
      <xsl:apply-templates 
        select="*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]" 
        mode="dita-ot:text-only"/>
    </xsl:when>
    <xsl:when test="not(*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]) and @navtitle"><xsl:value-of select="@navtitle"/></xsl:when>

    <!-- If this references a DITA file (has @href, not "local" or "external"),
         try to open the file and get the title -->
    <xsl:when test="@href and not(@href='') and 
                    not ((ancestor-or-self::*/@scope)[last()]='external') and
                    not ((ancestor-or-self::*/@scope)[last()]='peer') and
                    not ((ancestor-or-self::*/@type)[last()]='external') and
                    not ((ancestor-or-self::*/@type)[last()]='local')">
      <xsl:apply-templates select="." mode="getNavtitleFromTopic">
        <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
      </xsl:apply-templates>
    </xsl:when>

    <!-- If there is no title and none can be retrieved, check for <linktext> -->
    <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
      <xsl:apply-templates 
        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>

    <!-- No local title, and not targeting a DITA file. Could be just a container setting
         metadata, or a file reference with no title. Issue message for the second case. -->
    <xsl:otherwise>
      <xsl:if test="@href and not(@href='')">
          <xsl:apply-templates select="." mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
            <xsl:with-param name="target" select="@href"/>
            <xsl:with-param name="fallback" select="@href"/>
          </xsl:apply-templates>
          <xsl:value-of select="@href"/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="getNavtitleFromTopic">
  <xsl:param name="WORKDIR"/>
  <!-- Need to worry about targeting a nested topic? Not for now. -->
  <xsl:variable name="FileWithPath">
    <xsl:choose>
      <xsl:when test="@copy-to and not(contains(@chunk, 'to-content'))">
        <xsl:value-of select="$WORKDIR"/><xsl:value-of select="@copy-to"/>
        <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
          <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="contains(@href,'#')">
        <xsl:value-of select="$WORKDIR"/><xsl:value-of select="substring-before(@href,'#')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$WORKDIR"/><xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="TargetFile" select="document($FileWithPath,/)"/>

  <xsl:choose>
    <xsl:when test="not($TargetFile)">   <!-- DITA file does not exist -->
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">  <!-- attempt to recover by using linktext -->
          <xsl:apply-templates
             select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
             mode="dita-ot:text-only"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="ditamsg:missing-target-file-no-navtitle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <!-- First choice for navtitle: topic/titlealts/navtitle -->
    <xsl:when test="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/navtitle ')]">
      <xsl:apply-templates 
        select="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/navtitle ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>
    <!-- Second choice for navtitle: topic/title -->
    <xsl:when test="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
      <xsl:apply-templates 
        select="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>
    <!-- This might be a combo article; modify the same queries: dita/topic/titlealts/navtitle -->
    <xsl:when test="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/navtitle ')]">
      <xsl:apply-templates 
        select="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/navtitle ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>
    <!-- Second choice: dita/topic/title -->
    <xsl:when test="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
      <xsl:apply-templates 
        select="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>
    <!-- Last choice: use the linktext specified within the topicref -->
    <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
      <xsl:apply-templates 
        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
        mode="dita-ot:text-only"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
        <xsl:with-param name="target" select="$FileWithPath"/>
        <xsl:with-param name="fallback" select="'***'"/>
      </xsl:apply-templates>
      <xsl:text>***</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Link to user CSS. -->
<!-- Test for URL: returns "url" when the content starts with a URL;
  Otherwise, leave blank -->
<xsl:template name="url-string">
  <xsl:param name="urltext"/>
  <xsl:choose>
    <xsl:when test="contains($urltext,'http://')">url</xsl:when>
    <xsl:when test="contains($urltext,'https://')">url</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- Can't link to commonltr.css or commonrtl.css because we don't know what language the map is in. -->
	<xsl:template name="generateCssLinks">
		<xsl:variable name="childlang">
			<xsl:choose>
				<!-- Update with DITA 1.2: /dita can have xml:lang -->
				<xsl:when test="self::dita[not(@xml:lang)]">
					<xsl:for-each select="*[1]"><xsl:call-template name="getLowerCaseLang"/></xsl:for-each>
				</xsl:when>
				<xsl:otherwise><xsl:call-template name="getLowerCaseLang"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="direction">
			<xsl:apply-templates select="." mode="get-render-direction">
				<xsl:with-param name="lang" select="$childlang"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="urltest"> <!-- test for URL -->
			<xsl:call-template name="url-string">
				<xsl:with-param name="urltext">
					<xsl:value-of select="concat($CSSPATH, $CSS)"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="($direction = 'rtl') and ($urltest = 'url') ">
				<link rel="stylesheet" type="text/css" href="{$CSSPATH}{$bidi-dita-css}" />
			</xsl:when>
			<xsl:when test="($direction = 'rtl') and ($urltest = '')">
				<link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$bidi-dita-css}" />
			</xsl:when>
			<xsl:when test="($urltest = 'url')">
				<link rel="stylesheet" type="text/css" href="{$CSSPATH}{$dita-css}" />
			</xsl:when>
			<xsl:otherwise>
				<link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$dita-css}" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$newline"/>
		<!-- Add user's style sheet if requested to -->
		<xsl:if test="string-length($CSS) > 0">
			<xsl:choose>
				<xsl:when test="$urltest = 'url'">
					<link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" />
				</xsl:when>
				<xsl:otherwise>
					<link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" />
				</xsl:otherwise>
			</xsl:choose><xsl:value-of select="$newline"/>
		</xsl:if>
		
	</xsl:template>

<!-- To be overridden by user shell. -->

<xsl:template name="gen-user-head">
  <xsl:apply-templates select="." mode="gen-user-head"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-head">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the HEAD section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-header">
  <xsl:apply-templates select="." mode="gen-user-header"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-header">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the running heading section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-footer">
  <xsl:apply-templates select="." mode="gen-user-footer"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-footer">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- it will be placed in the running footing section of the XHTML. -->
</xsl:template>

<xsl:template name="gen-user-sidetoc">
  <xsl:apply-templates select="." mode="gen-user-sidetoc"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-sidetoc">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- Uncomment the line below to have a "freebie" table of contents on the top-right -->
</xsl:template>

<xsl:template name="gen-user-scripts">
  <xsl:apply-templates select="." mode="gen-user-scripts"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-scripts">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed before the ending HEAD tag -->
  <!-- see (or enable) the named template "script-sample" for an example -->
</xsl:template>

<xsl:template name="gen-user-styles">
  <xsl:apply-templates select="." mode="gen-user-styles"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-styles">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed before the ending HEAD tag -->
</xsl:template>

<xsl:template name="gen-user-external-link">
  <xsl:apply-templates select="." mode="gen-user-external-link"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-external-link">
  <!-- to customize: copy this to your override transform, add the content you want. -->
  <!-- It will be placed after an external LINK or XREF -->
</xsl:template>

<!-- These are here just to prevent accidental fallthrough -->
<!-- Deprecated: use "toc" mode instead -->
<xsl:template match="*[contains(@class, ' map/navref ')]"/>
<xsl:template match="*[contains(@class, ' map/anchor ')]"/>
<xsl:template match="*[contains(@class, ' map/reltable ')]"/>
<xsl:template match="*[contains(@class, ' map/topicmeta ')]"/>
<!--xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, '/topicgroup ')]"/-->

<!-- Deprecated: use "toc" mode instead -->
<xsl:template match="*">
  <xsl:apply-templates/>
</xsl:template>

<!-- Convert the input value to lowercase & return it -->
<xsl:template name="convert-to-lower">
 <xsl:param name="inputval"/>
 <xsl:value-of select="translate($inputval,
                                  '-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                  '-abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz')"/>
</xsl:template>

<!-- Template to get the relative path to a map -->
<xsl:template name="getRelativePath">
  <xsl:param name="remainingPath" select="@file"/>
  <xsl:choose>
    <xsl:when test="contains($remainingPath,'/')">
      <xsl:value-of select="substring-before($remainingPath,'/')"/><xsl:text>/</xsl:text>
      <xsl:call-template name="getRelativePath">
        <xsl:with-param name="remainingPath" select="substring-after($remainingPath,'/')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($remainingPath,'\')">
      <xsl:value-of select="substring-before($remainingPath,'\')"/><xsl:text>/</xsl:text>
      <xsl:call-template name="getRelativePath">
        <xsl:with-param name="remainingPath" select="substring-after($remainingPath,'\')"/>
      </xsl:call-template>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="ditamsg:missing-target-file-no-navtitle">
  <xsl:call-template name="output-message">
    <xsl:with-param name="msgnum">008</xsl:with-param>
    <xsl:with-param name="msgsev">W</xsl:with-param>
    <xsl:with-param name="msgparams">%1=<xsl:value-of select="@href"/></xsl:with-param>
   </xsl:call-template>
</xsl:template>

<xsl:template match="*" mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
  <xsl:param name="target"/>
  <xsl:param name="fallback"/>
  <xsl:call-template name="output-message">
    <xsl:with-param name="msgnum">009</xsl:with-param>
    <xsl:with-param name="msgsev">W</xsl:with-param>
    <xsl:with-param name="msgparams">%1=<xsl:value-of select="$target"/>;%2=<xsl:value-of select="$fallback"/></xsl:with-param>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
