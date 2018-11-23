
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['fileUuid'] = "">
<cfset data['likes'] = 0>
<cfset data['add'] = 0>
<cfset data['userToken'] = "">
<cfset data['error'] = "">
<cfset data['allowMultipleLikesPerUser'] = 0>

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfset data['fileUuid'] = LCase(requestBody['id'])>
  <cfset data['add'] = requestBody['add']>
  <cfset data['userToken'] = LCase(requestBody['userToken'])>
  <cfset data['allowMultipleLikesPerUser'] = requestBody['allowMultipleLikesPerUser']>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfset data['fileUuid'] = LCase(requestBody['id'])>
      <cfset data['add'] = requestBody['add']>
      <cfset data['userToken'] = LCase(requestBody['userToken'])>
      <cfset data['allowMultipleLikesPerUser'] = requestBody['allowMultipleLikesPerUser']>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<!---<cfdump var="#requestBody#" abort />--->

<cfif Val(data['add'])>
  <!---<cfdump var="#requestBody#" abort />--->
  <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblFile 
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
  </CFQUERY>
  <cfset allowMultipleLikesPerUser = true>
  <cfif Len(Trim(data['userToken'])) AND NOT data['allowMultipleLikesPerUser']>
    <CFQUERY NAME="qGetFileUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFileUser
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> AND User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
    </CFQUERY>
    <cfif qGetFileUser.RecordCount>
	  <cfset allowMultipleLikesPerUser = false>
    </cfif>
  </cfif>
  <cfif qGetFile.RecordCount AND allowMultipleLikesPerUser AND Len(Trim(data['userToken']))>
	<cfset likes = Val(qGetFile.Likes) + 1>
    <CFQUERY NAME="qUpdateFile" DATASOURCE="#request.domain_dsn#">
      UPDATE tblFile
      SET Likes = <cfqueryparam cfsqltype="cf_sql_integer" value="#likes#"> 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
    </CFQUERY>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        INSERT INTO tblFileUser (User_ID,File_uuid,User_token) 
        VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">)
      </CFQUERY>
    </cfif>
  <cfelse>
	<cfset data['error'] = "Like could not be added to the database">
  </cfif>
</cfif>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
</CFQUERY>
<cfif qGetFile.RecordCount>
  <cfset data['likes'] = qGetFile.Likes>
</cfif>

<cfset data = SerializeJSON(data)>

<cfoutput>
#data#
</cfoutput>