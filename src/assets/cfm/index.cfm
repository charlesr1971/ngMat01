<cfoutput>

    <cfparam name="ngdomid" default="#RandRange(1000000,9999999)#">
    
    <!---<cfparam name="signUpValidated" default="0">--->
    
    <!---#request.filepathasset#\lib\jBCrypt-0.4
    
    <cfabort />--->
    
    <cfif StructKeyExists(url,"signUpToken")>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE SignUpToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.signUpToken#">
      </CFQUERY>
      <cfif qGetUser.RecordCount>
        <CFQUERY NAME="qUpdateSignUpValidated" DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> 
          WHERE SignUpToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.signUpToken#">
        </CFQUERY>
      </cfif>
    </cfif>
    
    <iframe id="ng-#ngdomid#" name="ng-#ngdomid#" src="#request.ngIframeSrc#?port=#request.cfport#&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&ngdomid=#ngdomid#" width="100%" height="100%" frameborder="0"></iframe>

</cfoutput>