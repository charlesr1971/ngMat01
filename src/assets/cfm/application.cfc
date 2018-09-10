<cfcomponent>
	<cfscript>

		this.name = hash( getCurrentTemplatePath() );
		this.applicationTimeout = CreateTimeSpan( 2, 0, 0, 0 );
		
		this.currentTemplatePathDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
		this.mappings = {
		  "/components" = this.currentTemplatePathDirectory & "components\"
		};
		
		/*
		
		Uncomment the following code to take advantage of Coldfusion 10+ 'this.javasettings'.
		The load path works within its default installation, but if you move the '.jar' file or change the directory structure within the web root, you will need to refactor the load path.
		Please remember to restart the Coldfusion Application Server, after uncommenting the code below.
				
		*/

		/*
		
		this.javaSettings = { 
		  loadPaths = [".\assets\core\lib\chamika-jwt-sign-encrypt\chamika-jwt-sign-encrypt-1.0.8.jar"]
		};
		
		*/

		function onApplicationStart(){

		  return true;
		  
		}

		function onRequestStart( targetpath ){
			
		  if( StructKeyExists( url, "appreload" ) ){
			OnApplicationStart();
			this.applicationTimeout = CreateTimeSpan( 0, 0, 0, 1 );
		  }

		  request.crptographyencoding = "Hex";
		  request.crptographyalgorithm = "AES";
		  request.basePathFull = this.currentTemplatePathDirectory;
		  request.basePath = REReplaceNoCase( request.basePathFull, "\\$", "", "ALL" );
		  request.webroot = ExpandPath( "/" );
		  request.filepath = request.basePath;
		  request.assetdirectory = "assets/core/";
		  request.assetdir = "";
		  
		  if( Len( Trim( request.assetdirectory ) ) ){
			request.assetdir = "/" & Mid( request.assetdirectory, 1, Len( request.assetdirectory )-1 );
		  }
		  
		  request.filepathasset = request.filepath & ReplaceNoCase( request.assetdir, '/', '\', 'ALL' );
		  
		  request.rootdir = "";
		  request.equalswebroot = false;
		  request.clientdir = ReplaceNoCase( request.basePathFull, request.webroot, "", "ALL" );
		  request.clientdir = REReplaceNoCase( request.clientdir, "\\$", "", "ALL" );
		  
		  if( Len( Trim( request.clientdir ) ) ){
			  
			if( ListLen( request.clientdir, "\" ) ){
			  request.clientdir = ListGetAt( request.clientdir, ListLen( request.clientdir, "\" ), "\" );
			  request.rootdir = "/" & request.clientdir;
			}
			
		  }
		  else{
			  
			request.equalswebroot = true;
			
			if( Len( Trim( request.webroot ) ) ){
				
			  if( ListLen( request.webroot, "\" ) ){
				request.clientdir = ListGetAt( request.webroot, ListLen( request.webroot, "\" ), "\" );
			  }
			  
			}
			
		  }
		  
		  
		  local.ngport = 4200;
		  local.host = ListFirst(CGI.HTTP_HOST,":");
		  request.absoluteBaseUrl = "http://" & CGI.HTTP_HOST;
		  if(IsLocalHost(CGI.REMOTE_ADDR)){
			local.host = ListAppend(local.host,local.ngport,":");
		  }
		  request.ngAccessControlAllowOrigin = "http://" & local.host;
		  		  
		  return true;
		  
		}

	</cfscript>
</cfcomponent>