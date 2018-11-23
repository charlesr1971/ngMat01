
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="file-name, image-path, name, title, description, file-extension, user-token, content-type, user-id" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="extensions" default="gif,png,jpg,jpeg" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="fileid" default="#CreateUUID()#" />
<cfparam name="filename" default="" />
<cfparam name="maxcontentlength" default="2500000" />
<cfparam name="submissiondate" default="#Now()#" />

<cfinclude template="functions.cfm">

<cfset data = StructNew()>
<cfset data['clientfileName'] = "">
<cfset data['imagePath'] = "">
<cfset data['name'] = "">
<cfset data['title'] = "">
<cfset data['description'] = "None available">
<cfset data['fileExtension'] = "">
<cfset data['selectedFile'] = "">
<cfset data['success'] = false>
<cfset data['error'] = "">
<cfset data['content_length'] = 0>
<cfset data['fileUuid'] = fileid>
<cfset data['userToken'] = "">
<cfset data['userId'] = 0>
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>

<cftry>
  <cfset data['clientfileName'] = getHttpRequestData().headers['file-name']>
  <cfset data['imagePath'] = getHttpRequestData().headers['image-path']>
  <cfset data['name'] = getHttpRequestData().headers['name']>
  <cfset data['title'] = getHttpRequestData().headers['title']>
  <cfset data['description'] = getHttpRequestData().headers['description']>
  <cfset data['fileExtension'] = getHttpRequestData().headers['file-extension']>
  <cfset data['selectedFile'] = getHttpRequestData().content>
  <cfset data['content_length'] = getHttpRequestData().headers['content-length']>
  <cfset data['userToken'] = getHttpRequestData().headers['user-token']>
  <!---<cfset data['cfid'] = getHttpRequestData().headers['cfid']>
  <cfset data['cftoken'] = getHttpRequestData().headers['cftoken']>--->
  <!---<cfdump var="#getHttpRequestData()#" abort />--->
  <cfcatch>
  </cfcatch>
</cftry>

<cfif Len(Trim(data['imagePath'])) AND Len(Trim(data['fileExtension'])) AND ListFindNoCase(extensions,data['fileExtension']) AND IsBinary(data['selectedFile']) AND IsNumeric(data['content_length']) AND Val(data['userId'])>
  <cfif data['content_length'] LT maxcontentlength>
    <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
    <cfset imageSystemPath = ReplaceNoCase(imagePath,"/","\","ALL")>
    <cfset imageSystemPath = request.filepath & imageSystemPath>
    <cfset author = REReplaceNoCase(data['name'],"[[:punct:]]","","ALL")>
	<cfset author = REReplaceNoCase(author,"[\s]+"," ","ALL")>
    <cfset author = Trim(author)>
    <cfset author = FormatTitle(author)>
    <cfset title = REReplaceNoCase(data['title'],"[[:punct:]]","","ALL")>
	<cfset title = REReplaceNoCase(title,"[\s]+"," ","ALL")>
    <cfset title = Trim(title)>
    <cfset title = FormatTitle(title)>
    <cfif DirectoryExists(imageSystemPath)>
      <cfset data['success'] = true>
      <cflock name="write_file_#timestamp#" type="exclusive" timeout="30">
        <cffile action="write" file="#imageSystemPath#/#fileid#.#data['fileExtension']#" output="#data['selectedFile']#" />
      </cflock>
      <!---<cfset data['imagePath'] = uploadfolder & imagePath & "/" & fileid & "." & data['fileExtension']>--->
      <cfset imagePath = REReplaceNoCase(imagePath,"^/","")>
      <cfset data['imagePath'] = imagePath & "/" & fileid & "." & data['fileExtension']>
    </cfif>
    <cfset filename = fileid & "." & data['fileExtension']>
    <CFQUERY DATASOURCE="#request.domain_dsn#">
      INSERT INTO tblFile (User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Size,Cfid,Cftoken,User_token,Submission_date) 
      VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#data['userId']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(fileid)#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(imagePath,'/')#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['clientfileName']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#filename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['imagePath']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#author#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#title#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#data['description']#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#Val(data['content_length'])#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(data['userToken'])#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#submissiondate#">)
    </CFQUERY>
  <cfelse>
	<cfset maxcontentlengthInMb = NumberFormat(maxcontentlength/1000000,".__")>
    <cfset data['error'] = "The image uploaded must be less than " & maxcontentlengthInMb & "MB">
  </cfif>
<cfelse>
  <cfset data['error'] = "Data uploaded was insufficient to complete the submission">
</cfif>

<cfif IsBinary(data['selectedFile'])>
  <cfset data['selectedFile'] = ToBase64(ToString(data['selectedFile']),"utf-8")>
</cfif>

<cfoutput>
#SerializeJson(data)#
</cfoutput>