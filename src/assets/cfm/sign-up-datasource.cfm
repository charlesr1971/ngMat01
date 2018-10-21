
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="thealgorithm" default="#request.crptographyalgorithm#">
<cfparam name="thekey" default="#request.crptographykey#">
<cfparam name="signuptoken" default="#LCase(CreateUUID())#" />
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['email'] = "">
<cfset data['salt'] = thekey>
<cfset data['password'] = "">
<cfset data['usertoken'] = "">
<cfset data['signuptoken'] = signuptoken>
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfset data['forename'] = Trim(requestBody['forename'])>
  <cfset data['surname'] = Trim(requestBody['surname'])>
  <cfset data['email'] = Trim(requestBody['email'])>
  <cfset data['password'] = Trim(requestBody['password'])>
  <cfset data['usertoken'] = Trim(requestBody['userToken'])>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfset data['forename'] = Trim(requestBody['forename'])>
	  <cfset data['surname'] = Trim(requestBody['surname'])>
      <cfset data['email'] = Trim(requestBody['email'])>
      <cfset data['password'] = Trim(requestBody['password'])>
      <cfset data['usertoken'] = Trim(requestBody['userToken'])>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">
</CFQUERY>
<cfif NOT qGetUser.RecordCount AND Len(Trim(data['password']))>
  <cfset encryptedstring = Encrypts(data['password'],data['salt'])>
  <cfset data['password'] = Hashed(encryptedstring,request.lckbcryptlib)>
  <CFQUERY DATASOURCE="#request.domain_dsn#" result="queryInsertResult">
	INSERT INTO tblUser (Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,User_token,SignUpToken) 
	VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['salt']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['password']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['forename']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['surname']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.cfid#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.cftoken#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['signuptoken']#">)
  </CFQUERY>
  <cfset data['userid'] = queryInsertResult.generatedkey>
  <cfset data['createdat'] = Now()>
<cfelse>
  <cfset data['error'] = "User already registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>