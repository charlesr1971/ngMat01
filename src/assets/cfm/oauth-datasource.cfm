
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="thealgorithm" default="#request.crptographyalgorithm#">
<cfparam name="thekey" default="#request.crptographykey#">
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['email'] = "">
<cfset data['salt'] = thekey>
<cfset data['password'] = "">
<cfset data['userid'] = 0>
<cfset data['authenticated'] = 0>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfset data['email'] = Trim(requestBody['email'])>
  <cfset data['password'] = Trim(requestBody['password'])>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfset data['email'] = Trim(requestBody['email'])>
	  <cfset data['password'] = Trim(requestBody['password'])>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetSalt" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> 
</CFQUERY>
<cfif qGetSalt.RecordCount>
  <cfset salt = "">
  <cfset hashencryptedstring = "">
  <cfif qGetSalt.RecordCount>
    <cfset salt = qGetSalt.Salt>
    <cfset hashencryptedstring = qGetSalt.Password>
  </cfif>
  <cfif Len(Trim(data['password']))>
    <cftry>
      <cfset password = Encrypts(data['password'],salt)>
      <cfcatch>
        <cfset password = "">
      </cfcatch>
    </cftry>
  <cfelse>
    <cfset password = "">
  </cfif>
  <cfset hashmatched = HashMatched(password,hashencryptedstring,request.lckbcryptlib)>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#"> AND Salt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#salt#"> 
  </CFQUERY>
  <cfif qGetUser.RecordCount AND Len(Trim(data['password'])) AND hashmatched>
    <cfset data['salt'] = qGetUser.Salt>
    <cfset data['userid'] = qGetUser.User_ID>
    <cfset data['authenticated'] = 1>
  </cfif>
<cfelse>
  <cfset data['error'] = "User has not registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>