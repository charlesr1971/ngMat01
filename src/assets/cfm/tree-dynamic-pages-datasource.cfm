
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="functions.cfm">

<cfset data['pages'] = 0>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
</CFQUERY>

<cfif qGetFile.RecordCount>
  <cfset data['pages'] = Int(qGetFile.RecordCount/request.batch)>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>