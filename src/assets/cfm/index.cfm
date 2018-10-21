<cfoutput>

    <cfparam name="ngdomid" default="#RandRange(1000000,9999999)#">
    
    <!---#request.filepathasset#\lib\jBCrypt-0.4
    
    <cfabort />--->

    <iframe id="ng-#ngdomid#" name="ng-#ngdomid#" src="#request.ngIframeSrc#?port=#request.cfport#&ngdomid=#ngdomid#" width="100%" height="100%" frameborder="0">
    </iframe>

</cfoutput>