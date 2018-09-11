
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
          <cfif Len(Trim(directory)) AND FindNoCase(".",ListLast(directory,"\")) AND FindNoCase("_",ListLast(directory,"\"))>
            <cfset data = StructNew()>
            <cfset data['category'] = ListLast(key,"\")>
            <cfset src = Trim(REReplaceNoCase(directory,"[\\]+","/","ALL"))>
            <cfset data['src'] = uploadfolder & src>
            <cfset filename = ListLast(src,"/")>
            <cfset filenameWithoutExtension = ListFirst(filename,".")>
            <cfset author = Trim(ListFirst(filenameWithoutExtension,"_"))>
            <cfset author = REReplaceNoCase(author,"[\s]+"," ","ALL")>
            <cfset author = REReplaceNoCase(author,"-"," ","ALL")>
            <cfset data['author'] = FormatTitle(author)>
            <cfset title = Trim(ListGetAt(filenameWithoutExtension,2,"_"))>
            <cfset title = REReplaceNoCase(title,"[\s]+"," ","ALL")>
            <cfset title = REReplaceNoCase(title,"-"," ","ALL")>
            <cfset data['title'] = FormatTitle(title)>
            <cfset fileid = "">
            <cfif ListLen(filenameWithoutExtension,"_") GT 2>
			  <cfset fileid = Trim(ListGetAt(filenameWithoutExtension,3,"_"))>
            </cfif>
            <cfset data['description'] = "">
            <cfif Trim(Len(fileid))>
			  <cfset descriptionSystemPath = request.filepath & "/image-descriptions">
              <cflock name="read_file_#timestamp#" type="exclusive" timeout="30">
                <cffile action="read" file="#descriptionSystemPath#/#filenameWithoutExtension#.txt" variable="description" />
              </cflock>
              <cfset data['description'] = description>
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