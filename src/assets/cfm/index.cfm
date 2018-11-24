<cfoutput>

  <cfparam name="ngdomid" default="#RandRange(1000000,9999999)#">
  
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
    
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    
  <html xmlns="http://www.w3.org/1999/xhtml">
    
    <head>
      
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=yes">
      <title>Photo Gallery</title>
      <script type="text/javascript">
		location.href = "#request.ngIframeSrc#?port=#request.cfport#&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&ngdomid=#ngdomid#";
	  </script>
    </head>
    <body>
    
    </body>
  </html>

</cfoutput>