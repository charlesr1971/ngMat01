
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['email'] = "">
<cfset data['salt'] = "">
<cfset data['password'] = "">
<cfset data['usertoken'] = "">
<cfset data['signuptoken'] = "">
<cfset data['signUpValidated'] = 0>
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfset data['usertoken'] = Trim(requestBody['userToken'])>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
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
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#">
</CFQUERY>
<cfif qGetUser.RecordCount>
  <cfset data['userid'] = qGetUser.User_ID>
  <cfset data['forename'] = qGetUser.Forename>
  <cfset data['surname'] = qGetUser.Surname>
  <cfset data['email'] = qGetUser.E_mail>
  <cfset data['salt'] = qGetUser.Salt>
  <cfset data['password'] = qGetUser.Password>
  <cfset data['usertoken'] = qGetUser.User_token>
  <cfset data['signuptoken'] = qGetUser.SignUpToken>
  <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
  <cfset data['createdat'] = qGetUser.Submission_date>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>