
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
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
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>
<cfset data['signuptoken'] = signuptoken>
<cfset data['signUpValidated'] = 0>
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
  <cfset data['cfid'] = Trim(requestBody['cfid'])>
  <cfset data['cftoken'] = Trim(requestBody['cftoken'])>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfset data['forename'] = Trim(requestBody['forename'])>
	  <cfset data['surname'] = Trim(requestBody['surname'])>
      <cfset data['email'] = Trim(requestBody['email'])>
      <cfset data['password'] = Trim(requestBody['password'])>
      <cfset data['usertoken'] = Trim(requestBody['userToken'])>
      <cfset data['cfid'] = Trim(requestBody['cfid'])>
      <cfset data['cftoken'] = Trim(requestBody['cftoken'])>
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
	VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['salt']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['password']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['forename']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['surname']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['signuptoken']#">)
  </CFQUERY>
  <cfset data['userid'] = queryInsertResult.generatedkey>
  <cfset data['createdat'] = Now()>
  <cfmail to="#data['email']#" from="cdesign@btinternet.com" server="mail.btinternet.com" username="cdesign@btinternet.com" password="Charles581321" port="25" useSSL="no" useTLS="no" subject="Validate e-mail from Photo Gallery" type="html">
    <p><strong>Please validate e-mail:</strong></p>
    <a href="#uploadfolder#/index.cfm?signUpToken=#data['signuptoken']#">Validate E-mail</a>
  </cfmail>
<cfelse>
  <cfset data['error'] = "User already registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>