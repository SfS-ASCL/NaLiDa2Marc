<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
		xmlns="http://www.loc.gov/MARC21/slim"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:cmd="http://www.clarin.eu/cmd/"
		xmlns:cmde="http://www.clarin.eu/cmd/1"		
		xmlns:foo="foo.com">
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
            
        <xsl:template match="/">
                    
		<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" >
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
			<xsl:for-each select="//cmd:MdSelfLink">
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
			<xsl:for-each select="//cmd:Creation/cmd:Creators/cmd:Person[1]">
				<datafield tag="100" ind1="1" ind2=" ">
                                    <xsl:for-each select="./cmd:AuthoritativeIDs/cmd:AuthoritativeID">
                                        <xsl:if test="./cmd:issuingAuthority = 'GND' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./cmd:id)" />
					  </subfield>
                                        </xsl:if>
                                        <xsl:if test="./cmd:issuingAuthority = 'VIAF' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./cmd:id)" />
					  </subfield>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <subfield code="a">
                                        <xsl:value-of select="concat( ./cmd:lastName, ', ', ./cmd:firstName)" />
                                    </subfield>
				</datafield>
			</xsl:for-each>
                        
                        <!-- Here, we re-use the transformations taken from the standard DC to MARC21 script
                             adapted to our namespace -->
                        
			<xsl:for-each select="//cmd:DcmiTerms/cmd:contributor">
				<datafield tag="720" ind1="0" ind2="0">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="e">collaborator</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:coverage">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:creator">
				<datafield tag="720" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="e">author</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:date">
				<datafield tag="260" ind1=" " ind2=" ">
					<subfield code="c">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>	

			<xsl:for-each select="//cmd:DcmiTerms/cmd:description">
				<datafield tag="520" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<xsl:for-each select="//cmd:DcmiTerms/cmd:format">
				<datafield tag="856" ind1=" " ind2=" ">
					<subfield code="q">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:identifier">
				<datafield tag="024" ind1="8" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:language">
				<datafield tag="546" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<xsl:for-each select="//cmd:DcmiTerms/cmd:publisher">
				<datafield tag="260" ind1=" " ind2=" ">
					<subfield code="b">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:relation">
				<datafield tag="787" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:rights">
				<datafield tag="540" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:source">
				<datafield tag="786" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>

			<xsl:for-each select="//cmd:DcmiTerms/cmd:subject">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
																							
			

			

			<xsl:for-each select="//cmd:DcmiTerms/cmd:type">
				<datafield tag="655" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">local</subfield>
				</datafield>
			</xsl:for-each>
                        
                        <!-- Title Statement derived from DcmiTerms Profile -->
                        <!-- Extra choose for titles that have ':' in their string -->
                        <xsl:for-each select="//cmd:DcmiTerms/cmd:title[1]">
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
                        
                        <xsl:for-each select="//cmd:DcmiTerms/cmd:title[position()>1]">
				<datafield tag="246" ind1="3" ind2="3">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
                        </xsl:for-each>
                        
                        <!-- Here continues the use of the standard NaLiDa profiles -->
                        <!-- ====================================================== -->
                        
			<!-- Title Statement-->
                        <xsl:for-each select="//cmd:GeneralInfo/cmd:ResourceTitle[1]">
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
			<xsl:for-each select="//cmd:GeneralInfo/cmd:ResourceTitle[position()>1]">
				<datafield tag="246" ind1="3" ind2="3">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Address, $u would be email address: no street name, $a cityName, $b InstitutionName (todo) -->
			<xsl:for-each select="//cmd:GeneralInfo">
				<datafield tag="260" ind1="1" ind2="0">
					<subfield code="a">
						<xsl:value-of select="./cmd:LegalOwner"/>
					</subfield>
                                        <subfield code="b">
						<xsl:value-of select="./..//cmd:Department"/>
					</subfield>
                                        <subfield code="c">
						<xsl:value-of select="./cmd:PublicationDate"/>
					</subfield>
				</datafield>
			</xsl:for-each>	

                        <!-- Sizeinfo, only the last entry of SizeInfo is taken (assp last version)-->
			<xsl:for-each select="//cmd:TechnicalInfo[position()=last()]/cmd:SizeInfo">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
					<xsl:for-each select="./cmd:TotalSize">
						<xsl:value-of select="./cmd:Size"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="./cmd:SizeUnit"/>
						<xsl:if test="position() != last()">
							<xsl:text>, </xsl:text>
				     	</xsl:if>
					</xsl:for-each>		
					</subfield>
				</datafield>
			</xsl:for-each>		
                        
			<!-- General information for which a specialized 5XX note field has not been defined. -->
			<xsl:for-each select="//cmd:GeneralInfo/cmd:TimeCoverage">
				<datafield tag="500" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>	
                        	
			<!-- Formatted Contents Note -->
			<xsl:for-each select="//cmd:Access/cmd:DeploymentToolInfo">
				<datafield tag="505" ind1="0" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="./cmd:DeploymentTool"/>
						<xsl:text>: </xsl:text>
						<xsl:value-of select="normalize-space(./cmd:Descriptions/cmd:Description)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
                        
			<!-- Restrictions on Access Note -->
			<xsl:for-each select="//cmd:Access">
				<datafield tag="506" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="normalize-space(./cmd:Availability)"/>
						<xsl:text>, </xsl:text>
						<xsl:value-of select="normalize-space(./cmd:Price)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Unformatted information that describes the scope and general contents of the materials. -->
			<xsl:for-each select="//cmd:GeneralInfo/cmd:Descriptions/cmd:Description">
				<datafield tag="520" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="normalize-space(.)"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Funder -->
			<xsl:for-each select="//cmd:Project/cmd:Funder">
				<datafield tag="536" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="./cmd:fundingAgency"/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Information Relating to Copyright Status, wird nicht umgesetzt -->
<!--			<xsl:for-each select="//cmd:GeneralInfo/cmd:LegalOwner">
				<datafield tag="542" ind1="1" ind2=" ">
					<subfield code="b">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>-->
			
			<!-- Language Note -->
			<xsl:for-each select="//cmd:LexiconContext/cmd:SubjectLanguages/cmd:Language/cmd:LanguageName">
				<datafield tag="546" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Entity and Attribute Information Note, wird nicht umgesetzt -->
<!--			<xsl:for-each select="//cmd:Creation/cmd:Annotation/cmd:AnnotationTypes/cmd:AnnotationType">
				<datafield tag="552" ind1=" " ind2=" ">
					 Fetch information from GermaNet 
					<subfield code="a">  Entity Type label 
						<xsl:text>Annotations</xsl:text>
					</subfield>
					<subfield code="b">  Entity type definition and source 
						<xsl:value-of select="./cmd:AnnotationLevelType"/>
					</subfield>
				</datafield>
			</xsl:for-each>-->
			
			<!-- Index Term-Uncontrolled -->
			<xsl:for-each select="//cmd:GeneralInfo/cmd:Genre">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- also addings the tags into this 653, alternatively, use 650 with source not specified --> 
			<xsl:for-each select="//cmd:GeneralInfo/cmd:tags/cmd:tag">
				<datafield tag="653" ind1=" " ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			
			
			<!-- Index Term-Genre/Form  -->
			<xsl:for-each select="//cmd:GeneralInfo/cmd:ResourceClass">
				<datafield tag="655" ind1="7" ind2=" ">
					<subfield code="a">
						<xsl:value-of select="."/>
					</subfield>
					<subfield code="2">local</subfield>
				</datafield>
			</xsl:for-each>
                        
			<!--  Added Entry-Uncontrolled Name -->
			<xsl:for-each select="//cmd:Creation/cmd:Creators/cmd:Person[position()>1]">
				<datafield tag="700" ind1="1" ind2=" ">
                                    <xsl:for-each select="./cmd:AuthoritativeIDs/cmd:AuthoritativeID">
                                        <xsl:if test="./cmd:issuingAuthority = 'GND' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./cmd:id)" />
					  </subfield>
                                        </xsl:if>
                                        <xsl:if test="./cmd:issuingAuthority = 'VIAF' ">
					  <subfield code="0">
                                               <xsl:value-of select="concat( '(uri)', ./cmd:id)" />
					  </subfield>
                                        </xsl:if>
                                    </xsl:for-each>
				    <subfield code="a">
                                        <xsl:value-of select="concat( ./cmd:lastName, ', ', ./cmd:firstName)" />
				    </subfield>
					
				</datafield>
			</xsl:for-each>	
			
			<!-- Data Source Entry -->
			<xsl:for-each select="//cmd:Creation/cmd:Source/cmd:OriginalSourcce">
				<datafield tag="786" ind1="0" ind2=" ">
					<subfield code="n">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
			
			<!-- Electronic Location and Access  -->
			<xsl:for-each select="//cmd:TextTechnical/cmd:MimeTypes/cmd:MimeType">
				<datafield tag="856" ind1=" " ind2=" ">
					<subfield code="q">
						<xsl:value-of select="."/>
					</subfield>
				</datafield>
			</xsl:for-each>
                        
			<xsl:for-each select="//cmd:Access">
                            <xsl:if test="cmd:DistributionMedium != ''">
				<datafield tag="856" ind1="4" ind2="0">
                                        <!-- Electronic format type -->
					<subfield code="q">
						<xsl:value-of select="./cmd:DistribitionMedium"/>
					</subfield>
                                        <!-- URL -->
                                        <subfield code="u">
						<xsl:value-of select="./cmd:CatalogueLink"/>
					</subfield>
				</datafield>
                            </xsl:if>
			</xsl:for-each>
		</record>
	</xsl:template>
</xsl:stylesheet>
