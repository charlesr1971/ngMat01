
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />

<cfparam name="uploadfolder" default="#request.absoluteBaseUrl#/angular/material/ngMat01/src/assets/cfm" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="functions.cfm">

<cfset qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories",type="file")>

<cfset directories = CleanArray(directories=ConvertDirectoryQueryToArray(query=qGetDirPlusId),formatWithKeys=true)>


<cfset temp = ArrayNew(1)>

<cfloop from="1" to="#ArrayLen(directories)#" index="i">
  <cfif IsStruct(directories[i]) AND NOT StructIsEmpty(directories[i])>
	<cfset directoryData = directories[i]>
    <cfloop collection="#directoryData#" item="key">
	  <cfif IsArray(directoryData[key])>
        <cfloop from="1" to="#ArrayLen(directoryData[key])#" index="ii">
		  <cfset directory = directoryData[key][ii]>
          <cfif Len(Trim(directory)) AND FindNoCase(".",ListLast(directory,"\"))>
            <cfset data = StructNew()>
            <cfset data['category'] = ListLast(key,"\")>
            <cfset src = Trim(REReplaceNoCase(directory,"[\\]+","/","ALL"))>
            <cfset data['src'] = uploadfolder & src>
            <cfset filename = ListLast(src,"/")>
            <cfset filenameWithoutExtension = ListFirst(filename,".")>
            <cfset fileid = filenameWithoutExtension>
            <cfset data['fileUuid'] =  LCase(fileid)>
            <cfset data['author'] = "">
            <cfset data['title'] = "">
            <cfset data['description'] = "">
            <cfset data['size'] = 0>
            <cfset data['userToken'] = "">
            <cfset data['createdAt'] = Now()>
            <cfif Trim(Len(fileid))>
              <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile
                WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">
              </CFQUERY>
              <cfif qGetFile.RecordCount>
				<cfset data['fileUuid'] = LCase(fileid)>
				<cfset data['author'] = FormatTitle(qGetFile.Author)>
				<cfset data['title'] = FormatTitle(qGetFile.Title)>
				<cfset data['description'] = qGetFile.Description>
                <cfset data['size'] = qGetFile.Size>
                <cfset data['likes'] = qGetFile.Likes>
                <cfset data['userToken'] = qGetFile.User_token>
                <cfset data['createdAt'] = qGetFile.Submission_date>
              </cfif>
            </cfif>
            <cfset ArrayAppend(temp,data)>
          </cfif>
        </cfloop>
      </cfif>
    </cfloop>
  </cfif>
</cfloop>

<cfset data = SerializeJSON(temp)>

<cfoutput>
#data#
</cfoutput>