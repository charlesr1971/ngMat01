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
    
    <!---<cfif StructKeyExists(cookie,"cftoken")>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE Cftoken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.cftoken#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
      </CFQUERY>
      <cfif qGetUser.RecordCount>
		<cfset signUpValidated = 1>
      </cfif>
    </cfif>
    
    signUpValidated: #signUpValidated#<br />
    cookie.cftoken: #cookie.cftoken#--->
    
  <!---<!doctype html>
  <html lang="en">
    <head>
      <title>Photo Gallery</title>--->
      
      <!---<script src="../js/jquery.js" type="text/javascript"></script>
      <script src="../js/js-cookie/src/js.cookie.js" type="text/javascript"></script>
      <script type="text/javascript">
		  jQuery(document).ready(function() {
			var userToken = Cookies.get('userToken');
			var url = "#request.uploadfolder#/user-token-datasource.cfm?t=" + Math.random() + "&usertoken" + userToken;
			jQuery.ajax({
			  url: url
			})
			.done(function(response){
			  var obj = JSON.parse(response);
			  console.log('getCategoryShareType(): linkedin: sdk: obj 3',obj);
			  if(!jQuery.isEmptyObject(obj) && "signUpValidated" in obj && !isNaN(jQuery.trim(obj['signUpValidated']))){
				jQuery(document.body).append('<iframe id="ng-#ngdomid#" name="ng-#ngdomid#" src="#request.ngIframeSrc#?port=#request.cfport#&signUpValidated=' + obj['signUpValidated'] + '&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&usertoken=' + userToken + '&ngdomid=#ngdomid#" width="100%" height="100%" frameborder="0"></iframe>');
			  }
			})
			.fail(function(jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: get user token(): ajax',errorMessage);
			  jQuery(document.body).append('<iframe id="ng-#ngdomid#" name="ng-#ngdomid#" src="#request.ngIframeSrc#?port=#request.cfport#&signUpValidated=0&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&usertoken=' + userToken + '&ngdomid=#ngdomid#" width="100%" height="100%" frameborder="0"></iframe>');
			});
			console.log('userToken: ',userToken);
		  });
	  </script>--->
      
    <!---</head>
    <body> --->

      <iframe id="ng-#ngdomid#" name="ng-#ngdomid#" src="#request.ngIframeSrc#?port=#request.cfport#&signUpValidated=0&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&ngdomid=#ngdomid#" width="100%" height="100%" frameborder="0"></iframe>
      
    <!---</body>
  </html>--->

</cfoutput>