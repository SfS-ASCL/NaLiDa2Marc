<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns="http://www.loc.gov/MARC21/slim"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
		xmlns:cmd="http://www.clarin.eu/cmd/"
		xmlns:cmde="http://www.clarin.eu/cmd/1"
		xmlns:functx="http://www.functx.com"
		xmlns:foo="foo.com"		
		exclude-result-prefixes="xs xd functx">
  
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 24, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> ttrippel, czinn</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xml" indent="yes"/>
        
    <!-- <xsl:strip-space elements="cmd:Description"/> -->
    <xsl:strip-space elements="*"/>
        
    <xsl:param name="stop-words-title" select="'Prof.', 'Prof', 'Dr.', 'Dr', 'PhD', 'PhD.'" />
    <xsl:variable name="regexTitle" 
                  select="concat('(^|\W)(', string-join($stop-words-title, '|'), ')', '(\W(', string-join($stop-words-title, '|'), '))*($|\W)')" />

    <xsl:function name="foo:processPersonNames">
      <xsl:param name="input"/>
      <xsl:sequence select="replace(foo:rewritePersonName( replace( replace($input, $regexTitle, '$1$5'), '^ +','')), '\s+$', '', 'm')"/>
    </xsl:function>
    
    <xsl:function name="foo:rewritePersonName">
      <xsl:param name="input"/>
      <xsl:sequence select="concat( tokenize($input, ' ')[last()], ', ', substring-before( $input, tokenize($input, ' ')[last()])  )"/>
    </xsl:function>
    
	<xsl:template match="/cmd:CMD/cmd:Header">
		<!-- CMDI 1.1 ignoring header -->
	</xsl:template>
	
	<xsl:template match="/cmde:CMD/cmde:Header">
		<!-- CMDI 1.2 ignoring header -->
	</xsl:template>
	
	<xsl:template match="/cmd:CMD/cmd:Resources">
		<!-- CMDI 1.1 ignoring resources -->
	</xsl:template>
	
	<xsl:template match="/cmde:CMD/cmde:Resources">
		<!-- CMDI 1.2 ignoring resources -->
	</xsl:template>
	
	<!-- ToolProfile:            clarin.eu:cr1:p_1447674760338 
		 TextCorpusProfile:      clarin.eu:cr1:p_1442920133046
		 LexicalResourceProfile: clarin.eu:cr1:p_1445542587893
		 ExperimentProfile:      clarin.eu:cr1:p_1447674760337
    -->
	
	<!-- This need to be OR'ed for all valid NaLiDa-based profiles -->
	<xsl:template match="/cmd:CMD/cmd:Components">
	  <xsl:choose>
	    <xsl:when test="contains(/cmd:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1447674760338')
			    or contains(/cmd:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1442920133046')
			    or contains(/cmd:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1445542587893')
			    or contains(/cmd:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1447674760337')">
	      <!-- CMDI 1.1 -->
	      <xsl:call-template name="mainProcessing"></xsl:call-template>	
	    </xsl:when>
	    <xsl:otherwise>
	      <error>
		<xsl:text>
		  Please use a valid CMDI schema v1.1 from the NaLiDa project.
		  Currently the following profiles are being supported:
		
		  - ToolProfile (clarin.eu:cr1:p_1447674760338),
		  - TextCorpusProfile ('clarin.eu:cr1:p_1442920133046),
		  - LexicalResourceProfile (clarin.eu:cr1:p_1445542587893), and
		  - ExperimentProfile (clarin.eu:cr1:p_1447674760337).
		</xsl:text>
	      </error>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<xsl:template match="/cmde:CMD/cmde:Components">
	  <xsl:choose>
	    <xsl:when test="contains(/cmde:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1447674760338')
			    or contains(/cmde:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1442920133046')
			    or contains(/cmde:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1445542587893')
			    or contains(/cmde:CMD/@xsi:schemaLocation, 'clarin.eu:cr1:p_1447674760337')">
	      <!-- CMDI 1.2 -->
	      <xsl:call-template name="mainProcessing"></xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
	      <error>
		<xsl:text>
		Please use a valid CMDI v1.2 schema from the NaLiDa project.
		Currently the following profiles are being supported:
		
		- ToolProfile (clarin.eu:cr1:p_1447674760338),
		- TextCorpusProfile ('clarin.eu:cr1:p_1442920133046),
		- LexicalResourceProfile (clarin.eu:cr1:p_1445542587893), and
		- ExperimentProfile (clarin.eu:cr1:p_1447674760337).</xsl:text>
	      </error>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
    <xsl:template name="mainProcessing">
		<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" >
			<xsl:element name="leader">
				<xsl:variable name="type" select="type"/> <!-- todo -->
				<xsl:variable name="leader06">
					<xsl:choose>
						<xsl:when test="$type='collection'">p</xsl:when>
						<xsl:when test="$type='dataset'">m</xsl:when>
						<xsl:when test="$type='event'">r</xsl:when>
						<xsl:when test="$type='image'">k</xsl:when>
						<xsl:when test="$type='interactive resource'">m</xsl:when>
						<xsl:when test="$type='service'">m</xsl:when>
						<xsl:when test="$type='software'">m</xsl:when>
						<xsl:when test="$type='sound'">i</xsl:when>
						<xsl:when test="$type='text'">a</xsl:when>
						<xsl:otherwise>a</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="leader07">
					<xsl:choose>
						<xsl:when test="$type='collection'">c</xsl:when>
						<xsl:otherwise>m</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="concat('      ',$leader06,$leader07,'         3u     ')"/>
			</xsl:element>
                        
                        <controlfield tag="007">cr||||||||||||</controlfield>
			
			<!-- Other Standard Identifier -->
			<xsl:for-each select="//*:MdSelfLink">
				<datafield tag="024" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
                                        <subfield code="2">hdl</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- 042 - Authentication Code -->
			<datafield tag="042" ind1=" " ind2=" ">
				<subfield code="a">cmdi</subfield>
			</datafield>


			<!-- first person in creator list is recorded in field 100, together with affiliation, if existing -->
			<xsl:for-each select="//*:Creation/*:Creators/*:Person[1]">
				<datafield tag="100" ind1="1" ind2=" ">
                                    <xsl:for-each select="./*:AuthoritativeIDs/*:AuthoritativeID">
                                        <xsl:if test="./*:issuingAuthority = 'GND' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./*:id)" />
					  </subfield>
                                        </xsl:if>
                                        <xsl:if test="./*:issuingAuthority = 'VIAF' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./*:id)" />
					  </subfield>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <subfield code="a">
                                        <xsl:value-of select="concat( ./*:lastName, ', ', ./*:firstName)" />
                                    </subfield>
				</datafield>
			</xsl:for-each>
                        
                        <!-- Here, we re-use the transformations taken from the standard DC to MARC21 script
                             adapted to our namespace -->
                        
			<xsl:for-each select="//*:DcmiTerms/*:contributor">
				<datafield tag="720" ind1="0" ind2="0">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="e">collaborator</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:coverage">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:creator">
				<datafield tag="720" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="e">author</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:date">
				<datafield tag="260" ind1=" " ind2=" ">
					<subfield code="c">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>	

			<xsl:for-each select="//*:DcmiTerms/*:description">
				<datafield tag="520" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<xsl:for-each select="//*:DcmiTerms/*:format">
				<datafield tag="856" ind1=" " ind2=" ">
					<subfield code="q">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:identifier">
				<datafield tag="024" ind1="8" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:language">
				<datafield tag="546" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<xsl:for-each select="//*:DcmiTerms/*:publisher">
				<datafield tag="260" ind1=" " ind2=" ">
					<subfield code="b">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:relation">
				<datafield tag="787" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:rights">
				<datafield tag="540" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:source">
				<datafield tag="786" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//*:DcmiTerms/*:subject">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
																							
			

			

			<xsl:for-each select="//*:DcmiTerms/*:type">
				<datafield tag="655" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">local</subfield>
				</datafield>
			</xsl:for-each>
                        
                        <!-- Title Statement derived from DcmiTerms Profile -->
                        <!-- Extra choose for titles that have ':' in their string -->
                        <xsl:for-each select="//*:DcmiTerms/*:title[1]">
                            <datafield tag="245" ind1="0" ind2="0">
                                <xsl:choose>
                                    <xsl:when test="contains(., ':')">
                                        <subfield code="a">
                                            <xsl:value-of select="substring-before(., ':')"/>
                                        </subfield>
                                        <subfield code="b">
                                            <xsl:value-of select="normalize-space(substring-after(., ':'))"/>
                                        </subfield>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <subfield code="a">
                                            <xsl:value-of select="."/>
                                        </subfield>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </datafield>
                        </xsl:for-each>
                        
                        <xsl:for-each select="//*:DcmiTerms/*:title[position()>1]">
				<datafield tag="246" ind1="3" ind2="3">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
                        </xsl:for-each>
                        
                        <!-- Here continues the use of the standard NaLiDa profiles -->
                        <!-- ====================================================== -->
                        
			<!-- Title Statement-->
                        <xsl:for-each select="//*:GeneralInfo/*:ResourceTitle[1]">
                            <datafield tag="245" ind1="0" ind2="0">
                                <xsl:choose>
                                    <xsl:when test="contains(., ':')">
                                        <subfield code="a">
                                            <xsl:value-of select="substring-before(., ':')"/>
                                        </subfield>
                                        <subfield code="b">
                                            <xsl:value-of select="normalize-space(substring-after(., ':'))"/>
                                        </subfield>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <subfield code="a">
                                            <xsl:value-of select="."/>
                                        </subfield>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </datafield>
                        </xsl:for-each>
			
			<!-- Varying form of title -->
			<xsl:for-each select="//*:GeneralInfo/*:ResourceTitle[position()>1]">
				<datafield tag="246" ind1="3" ind2="3">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Address, $u would be email address: no street name, $a cityName, $b InstitutionName (todo) -->
			<xsl:for-each select="//*:GeneralInfo">
				<datafield tag="260" ind1="1" ind2="0">
					<subfield code="a">
						<xsl:value-of select="./*:LegalOwner"/>
					</subfield>
                                        <subfield code="b">
						<xsl:value-of select="./..//*:Department"/>
					</subfield>
                                        <subfield code="c">
						<xsl:value-of select="./*:PublicationDate"/>
					</subfield>
				</datafield>
			</xsl:for-each>	

                        <!-- Sizeinfo, only the last entry of SizeInfo is taken (assp last version)-->
			<xsl:for-each select="//*:TechnicalInfo[position()=last()]/*:SizeInfo">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
					<xsl:for-each select="./*:TotalSize">
						<xsl:value-of select="./*:Size"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="./*:SizeUnit"/>
						<xsl:if test="position() != last()">
							<xsl:text>, </xsl:text>
				     	</xsl:if>
					</xsl:for-each>		
					</subfield>
				</datafield>
			</xsl:for-each>		
                        
			<!-- General information for which a specialized 5XX note field has not been defined. -->
			<xsl:for-each select="//*:GeneralInfo/*:TimeCoverage">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>	
                        	
			<!-- Formatted Contents Note -->
			<xsl:for-each select="//*:Access/*:DeploymentToolInfo">
				<datafield tag="505" ind1="0" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="./*:DeploymentTool"/>
						<xsl:text>: </xsl:text>
						<xsl:value-of select="normalize-space(./*:Descriptions/*:Description)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
                        
			<!-- Restrictions on Access Note -->
			<xsl:for-each select="//*:Access">
				<datafield tag="506" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="normalize-space(./*:Availability)"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="normalize-space(./*:Price)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Unformatted information that describes the scope and general contents of the materials. -->
			<xsl:for-each select="//*:GeneralInfo/*:Descriptions/*:Description">
				<datafield tag="520" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="normalize-space(.)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Funder -->
			<xsl:for-each select="//*:Project/*:Funder">
				<datafield tag="536" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="./*:fundingAgency"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Information Relating to Copyright Status, wird nicht umgesetzt -->
<!--			<xsl:for-each select="//*:GeneralInfo/*:LegalOwner">
				<datafield tag="542" ind1="1" ind2=" ">
					<subfield code="b">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>-->
			
			<!-- Language Note -->
			<xsl:for-each select="//*:LexiconContext/*:SubjectLanguages/*:Language/*:LanguageName">
				<datafield tag="546" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Entity and Attribute Information Note, wird nicht umgesetzt -->
<!--			<xsl:for-each select="//*:Creation/*:Annotation/*:AnnotationTypes/*:AnnotationType">
				<datafield tag="552" ind1=" " ind2=" ">
					 Fetch information from GermaNet 
					<subfield code="a">  Entity Type label 
						<xsl:text>Annotations</xsl:text>
					</subfield>
					<subfield code="b">  Entity type definition and source 
						<xsl:value-of select="./*:AnnotationLevelType"/>
					</subfield>
				</datafield>
			</xsl:for-each>-->
			
			<!-- Index Term-Uncontrolled -->
			<xsl:for-each select="//*:GeneralInfo/*:Genre">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- also addings the tags into this 653, alternatively, use 650 with source not specified --> 
			<xsl:for-each select="//*:GeneralInfo/*:tags/*:tag">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			
			
			<!-- Index Term-Genre/Form  -->
			<xsl:for-each select="//*:GeneralInfo/*:ResourceClass">
				<datafield tag="655" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">local</subfield>
				</datafield>
			</xsl:for-each>
                        
			<!--  Added Entry-Uncontrolled Name -->
			<xsl:for-each select="//*:Creation/*:Creators/*:Person[position()>1]">
				<datafield tag="700" ind1="1" ind2=" ">
                                    <xsl:for-each select="./*:AuthoritativeIDs/*:AuthoritativeID">
                                        <xsl:if test="./*:issuingAuthority = 'GND' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./*:id)" />
					  </subfield>
                                        </xsl:if>
                                        <xsl:if test="./*:issuingAuthority = 'VIAF' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./*:id)" />
					  </subfield>
                                        </xsl:if>
                                    </xsl:for-each>
				    <subfield code="a">
                                        <xsl:value-of select="concat( ./*:lastName, ', ', ./*:firstName)" />
				    </subfield>
					
				</datafield>
			</xsl:for-each>	
			
			<!-- Data Source Entry -->
			<xsl:for-each select="//*:Creation/*:Source/*:OriginalSourcce">
				<datafield tag="786" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Electronic Location and Access  -->
			<xsl:for-each select="//*:TextTechnical/*:MimeTypes/*:MimeType">
				<datafield tag="856" ind1=" " ind2=" ">
					<subfield code="q">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
                        
			<xsl:for-each select="//*:Access">
                            <xsl:if test="*:DistributionMedium != ''">
				<datafield tag="856" ind1="4" ind2="0">
                                        <!-- Electronic format type -->
					<subfield code="q">
						<xsl:value-of select="./*:DistribitionMedium"/>
					</subfield>
                                        <!-- URL -->
                                        <subfield code="u">
						<xsl:value-of select="./*:CatalogueLink"/>
					</subfield>
				</datafield>
                            </xsl:if>
			</xsl:for-each>
		</record>
	</xsl:template>
    
</xsl:stylesheet>
