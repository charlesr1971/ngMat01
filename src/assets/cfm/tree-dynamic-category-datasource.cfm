
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />

<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories")>

<cfset directories = CleanArray(directories=ConvertDirectoryQueryToArray(query=qGetDirPlusId),formatWithKeys=false)>

<cfset data = SerializeJSON(directories)>
<cfset data = ReplaceNoCase(data,"\","/","ALL")>

<cfoutput>
#data#
</cfoutput>