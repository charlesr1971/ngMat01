
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.batch#" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfif Val(page) AND Val(request.batch)>
  <cfif page GT 1>
    <!---<cfset startrow = Int((page - 1) * (request.batch + 1))>--->
    <cfset startrow = Int((page - 1) * request.batch) + 1>
    <cfset endrow = (startrow + request.batch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.batch) - 1>
  </cfif>
</cfif>

<cfset rowData = {"startrow"=startrow,"endrow"=endrow}>

<!---<cfdump var="#rowData#" format="html" output="C:\Users\Charles Robertson\Desktop\cfdump\#page#_#timestamp#.htm" />--->

<cfset temp = ArrayNew(1)>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
</CFQUERY>

<cfif qGetFile.RecordCount>
  <cfloop query="qGetFile" startrow="#startrow#" endrow="#endrow#">
    <cfset data = StructNew()>
    <cfset data['category'] = qGetFile.Category>
    <cfset data['src'] = qGetFile.ImagePath>
    <cfset data['fileUuid'] = qGetFile.File_uuid>
    <cfset data['author'] = FormatTitle(qGetFile.Author)>
    <cfset data['title'] = FormatTitle(qGetFile.Title)>
    <cfset data['description'] = qGetFile.Description>
    <cfset data['size'] = qGetFile.Size>
    <cfset data['likes'] = qGetFile.Likes>
    <cfset data['userToken'] = qGetFile.User_token>
    <cfset data['createdAt'] = qGetFile.Submission_date>
    <cfset ArrayAppend(temp,data)>
  </cfloop>
</cfif>

<cfset data = SerializeJSON(temp)>

<cfoutput>
#data#
</cfoutput>