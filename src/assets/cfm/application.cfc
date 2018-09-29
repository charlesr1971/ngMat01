<cfcomponent>
	<cfscript>

		this.name = hash( getCurrentTemplatePath() );
		this.applicationTimeout = CreateTimeSpan( 2, 0, 0, 0 );
		this.clientManagement = true;
		this.clientStorage = "registry";
		this.setClientCookies = true;
		this.sessionManagement = true;
		this.sessionTimeout = CreateTimeSpan(0,1,0,0);
		this.setDomainCookies = false;
		
		this.currentTemplatePathDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
		this.mappings = {
		  "/components" = this.currentTemplatePathDirectory & "components\"
		};

		function onApplicationStart() {

		  return true;
		  
		}

		function onSessionStart() {
		}		

		function onRequestStart( targetpath ) {
			
		  if( StructKeyExists( url, "appreload" ) ){
			OnApplicationStart();
			this.applicationTimeout = CreateTimeSpan( 0, 0, 0, 1 );
		  }
		  
		  request.domain_dsn = "ng-gallery";

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
		  
		  request.batch = 4;
		  		  
		  return true;
		  
		}
		
		function onRequest( string targetPage ) {
		  include arguments.targetPage;
		}
		
		function onRequestEnd() {
		}
		
		function onSessionEnd( struct SessionScope, struct ApplicationScope ) {
		}
		
		function onApplicationEnd( struct ApplicationScope ) {
		}
		
		function onError( any Exception, string EventName ) {
		}

	</cfscript>
</cfcomponent>