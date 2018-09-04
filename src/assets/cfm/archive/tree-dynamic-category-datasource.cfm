
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfdirectory action="list" directory="#request.filepath#/categories" name="qGetDir" sort="Directory, Name ASC" type="all" recurse="yes" />

<cfquery name="qGetDir" dbtype="query">
  SELECT Directory, Name 
  FROM qGetDir
</cfquery>

<cfset qGetDirPlusId = QueryNew("Id,ParentId,Directory,Name")>

<cfloop query="qGetDir">
  <cfset QueryAddRow(qGetDirPlusId)> 
  <cfset QuerySetCell(qGetDirPlusId,"Id",qGetDir.CurrentRow)>
  <cfset QuerySetCell(qGetDirPlusId,"ParentId","")>
  <cfset QuerySetCell(qGetDirPlusId,"Directory",qGetDir.Directory)>
  <cfset QuerySetCell(qGetDirPlusId,"Name",qGetDir.Name)>
</cfloop>

<cfquery name="qGetDirParent" dbtype="query">
  SELECT * 
  FROM qGetDirPlusId
</cfquery>

<cfset maxid = qGetDirPlusId.RecordCount + 1>

<!---<cfdump var="#qGetDirParent#" />--->

<!---<cfloop query="qGetDirParent">
  <cfquery name="qGetDirParentExists" dbtype="query">
    SELECT * 
    FROM qGetDirPlusId
    WHERE Directory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetDirParent.Directory#" /> AND Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="" />
  </cfquery>
  <cfif NOT qGetDirParentExists.RecordCount>
    <cfset QueryAddRow(qGetDirPlusId)> 
    <cfset QuerySetCell(qGetDirPlusId,"Id",maxid)>
    <cfset QuerySetCell(qGetDirPlusId,"ParentId",0)>
    <cfset QuerySetCell(qGetDirPlusId,"Directory",qGetDirParent.Directory)>
    <cfset QuerySetCell(qGetDirPlusId,"Name","")>
    <cfset maxid = maxid + 1>
  </cfif>
</cfloop>--->

<cfset parentDirectories = ListRemoveDuplicates(ValueList(qGetDirParent.Directory),",",true)>

<!---<cfdump var="#parentDirectories#" />--->

<cfloop list="#parentDirectories#" index="parentDirectory">
  <cfquery name="qGetDirParentExists" dbtype="query">
    SELECT * 
    FROM qGetDirPlusId
    WHERE Directory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#parentDirectory#" /> 
  </cfquery>
  <cfif qGetDirParentExists.RecordCount>
    <cfset QueryAddRow(qGetDirPlusId)> 
    <cfset QuerySetCell(qGetDirPlusId,"Id",maxid)>
    <cfset QuerySetCell(qGetDirPlusId,"ParentId",0)>
    <cfset QuerySetCell(qGetDirPlusId,"Directory",qGetDirParentExists.Directory)>
    <cfset QuerySetCell(qGetDirPlusId,"Name","")>
    <cfset maxid = maxid + 1>
  </cfif>
</cfloop>

<cfquery name="qGetDirParent" dbtype="query">
  SELECT * 
  FROM qGetDirPlusId
  WHERE ParentId = <cfqueryparam cfsqltype="cf_sql_varchar" value="0" />
</cfquery>

<!---<cfdump var="#qGetDirParent#" />--->

<cfloop query="qGetDirParent">
  <cfloop query="qGetDirPlusId">
	<!---<cfset path = qGetDirPlusId.Directory & "\" & qGetDirPlusId.Name>--->
    <!---<cfoutput>path: #path#<br /></cfoutput>--->
	<cfif CompareNoCase(qGetDirParent.Directory,qGetDirPlusId.Directory) EQ 0 AND qGetDirPlusId.ParentId NEQ 0>
	  <cfset qGetDirPlusId['ParentId'][qGetDirPlusId.CurrentRow] = qGetDirParent.Id>
    </cfif>
  </cfloop>
</cfloop>

<!---<cfdump var="#qGetDirPlusId#" />--->

<br /><br />

<cfset qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories")>

<cfset directories = CleanArray(directories=ConvertDirectoryQueryToArray(query=qGetDirPlusId))>

<cfset data = SerializeJSON(directories)>
<cfset data = ReplaceNoCase(data,"\","/","ALL")>

<cfdump var="#data#" />

<cfoutput>



</cfoutput>