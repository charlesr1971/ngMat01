
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type" />

<cfparam name="usertoken" default="">
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['signUpValidated'] = 0>

<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#usertoken#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
</CFQUERY>
<cfif qGetUser.RecordCount>
  <cfset data['signUpValidated'] = 1>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>