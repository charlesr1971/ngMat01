
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="image-path, name, title, file-extension, content-type" />

<cfparam name="uploadfolder" default="#request.absoluteBaseUrl#/angular/material/ngMat01/src/assets/cfm" />
<cfparam name="extensions" default="gif,png,jpg,jpeg" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="filename" default="#CreateUUID()#" />


<cfset data = StructNew()>
<cfset data['imagePath'] = "">
<cfset data['name'] = "">
<cfset data['title'] = "">
<cfset data['fileExtension'] = "">
<cfset data['selectedFile'] = "">
<cfset data['success'] = false>

<cftry>
  <cfset data['imagePath'] = getHttpRequestData().headers['image-path']>
  <cfset data['name'] = getHttpRequestData().headers['name']>
  <cfset data['title'] = getHttpRequestData().headers['title']>
  <cfset data['fileExtension'] = getHttpRequestData().headers['file-extension']>
  <cfset data['selectedFile'] = getHttpRequestData().content>
  <!---<cfdump var="#getHttpRequestData()#" />--->
  <cfcatch>
  </cfcatch>
</cftry>

<cfset _imagePath = "">
<cfset filename = "">

<cfif Len(Trim(data['imagePath'])) AND Len(Trim(data['fileExtension'])) AND ListFindNoCase(extensions,data['fileExtension']) AND IsBinary(data['selectedFile'])>
  <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
  <cfset _imagePath = imagePath>
  <cfset imageSystemPath = ReplaceNoCase(imagePath,"/","\","ALL")>
  <cfset imageSystemPath = request.filepath & imageSystemPath>
  <cfif Len(Trim(data['name']))>
	<cfset name = REReplaceNoCase(data['name'],"[[:punct:]]","","ALL")>
    <cfset name = REReplaceNoCase(name,"[\s]+","-","ALL")>
    <cfset name = Trim(LCase(name))>
	<cfset filename = name>
    <cfif Len(Trim(data['title']))>
	  <cfset filename = filename & "_">
    </cfif>
  </cfif>
  <cfif Len(Trim(data['title']))>
	<cfset title = REReplaceNoCase(data['title'],"[[:punct:]]","","ALL")>
    <cfset title = REReplaceNoCase(title,"[\s]+","-","ALL")>
    <cfset title = Trim(LCase(title))>
	<cfset filename = filename & title>
  </cfif>
  <cfif DirectoryExists(imageSystemPath)>
	<cfset data['success'] = true>
    <cflock name="write_file_#timestamp#" type="exclusive" timeout="30">
      <cffile action="write" file="#imageSystemPath#/#filename#.#data['fileExtension']#" output="#data['selectedFile']#" />
    </cflock>
    <cfset data['imagePath'] = uploadfolder & _imagePath & "/" & filename & "." & data['fileExtension']>
  </cfif>
  <cfset data['selectedFile'] = ToBase64(ToString(data['selectedFile']),"utf-8")>
</cfif>


<cfoutput>
#SerializeJson(data)#
</cfoutput>