<cfscript>


  public query function ParseDirectory(required string path, string type = "dir") output="true" {
	  
	var local = {};
	
	var aQuery = "";
	  		
	cfdirectory(action="list",directory=arguments.path,name="local.query1",sort="Directory, Name ASC",type=arguments.type,recurse="yes");

	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query1);
	local.objQueryResult = local.queryService.execute(sql="SELECT Directory, Name FROM sourceQuery");
	local.queryResult1 = local.objQueryResult.getResult();
	
	local.query2 = QueryNew("Id,ParentId,Directory,Name,GroupId");	
	
	if(local.queryResult1.RecordCount){
	  for(local.row in local.queryResult1){
		QueryAddRow(local.query2);
		QuerySetCell(local.query2,"Id",local.queryResult1.CurrentRow);
		QuerySetCell(local.query2,"ParentId","");
		QuerySetCell(local.query2,"Directory",local.row.Directory);
		QuerySetCell(local.query2,"Name",local.row.Name);
		QuerySetCell(local.query2,"GroupId","");
	  }
	}
	
	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query2);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery");
	local.queryResult2 = local.objQueryResult.getResult();
	
	local.maxid = local.query2.RecordCount + 1;
		
	local.parentDirectories = ListRemoveDuplicates(ValueList(local.queryResult2.Directory),",",true);
	
	for(local.item in ListToArray(local.parentDirectories)){
	  local.queryService = new query();
	  local.queryService.setDBType("query");
	  local.queryService.setAttributes(sourceQuery=local.query2);
	  local.queryService.addParam(name="Directory",value=local.item,cfsqltype="cf_sql_varchar"); 
	  local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE Directory = :Directory");
	  local.queryResult3 = local.objQueryResult.getResult();
	  if(local.queryResult3.RecordCount){
		QueryAddRow(local.query2); 
		QuerySetCell(local.query2,"Id",local.maxid);
		QuerySetCell(local.query2,"ParentId",0);
		QuerySetCell(local.query2,"Directory",local.queryResult3.Directory);
		QuerySetCell(local.query2,"Name","");
		QuerySetCell(local.query2,"GroupId",0);
		local.maxid = maxid + 1;
	  }
	}
		
	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query2);
	local.queryService.addParam(name="ParentId",value=0,cfsqltype="cf_sql_varchar"); 
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId = :ParentId");
	local.queryResult4 = local.objQueryResult.getResult();
	
	if(local.queryResult4.RecordCount){
	  for(local.rowParent in local.queryResult4){
		for(local.rowChild in local.query2){
		  if(CompareNoCase(local.rowParent.Directory,local.rowChild.Directory) EQ 0 AND local.rowChild.ParentId NEQ 0){
			local.query2['ParentId'][local.query2.CurrentRow] = local.rowParent.Id;
			local.query2['GroupId'][local.query2.CurrentRow] = local.rowParent.Id;
		  }
		}
	  }
	  for(local.rowParent in local.queryResult4){
		for(local.rowChild in local.query2){
		  if(CompareNoCase(local.rowParent.Directory,local.rowChild.Directory) EQ 0 AND local.rowChild.ParentId EQ 0){
			local.query2['GroupId'][local.query2.CurrentRow] = local.rowParent.Id;
		  }
		}
	  }
	  
	}
		
	return local.query2;
	
  }


  public any function ConvertDirectoryQueryToArray(required query query, numeric parentId = 0, array directories = ArrayNew(1), array nestedDirectories = ArrayNew(1), string parents = "") output="true" { 
  
	var local = {};
	
	var aQuery = "";
		
	local.directories = arguments.directories;
	local.nestedDirectories = arguments.nestedDirectories;
	local.parents = arguments.parents;
	
	local.queryService = new query();
	local.queryService.setName("aQuery");
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=arguments.query);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=0");
	local.queryResult = local.objQueryResult.getResult();
	
	if(NOT Len(Trim(local.parents))){
	  local.queryService = new query();
	  local.queryService.setName("aQuery");
	  local.queryService.setDBType("query");
	  local.queryService.setAttributes(sourceQuery=arguments.query);
	  local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=0");
	  local.queryResult = local.objQueryResult.getResult();
	  if(local.queryResult.RecordCount){
		for(local.row in local.queryResult){
		  local.directory = Trim(ReplaceNoCase(local.row.Directory & "\" & local.row.Name,request.filepath,""));
		  local.directory = REReplaceNoCase(local.directory,"(.*)\\[\s]*$","\1","ALL");
		  local.parents = ListAppend(local.parents,local.directory);
		}
	  }
	}
	
	local.queryService = new query();
	local.queryService.setName("aQuery");
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=arguments.query);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=#arguments.parentId#");
	local.queryResult = local.objQueryResult.getResult();
	
	if(local.queryResult.RecordCount){
	  for(local.row in local.queryResult){
		local.directory = Trim(ReplaceNoCase(local.row.Directory & "\" & local.row.Name,request.filepath,""));
		local.directory = REReplaceNoCase(local.directory,"(.*)\\[\s]*$","\1","ALL");
		if(NOT Len(Trim(local.row.Name))){
		  ArrayAppend(local.directories,local.directory);
		  local.nestedDirectories = ArrayNew(1);
		}
		else{
			if(NOT ListFindNoCase(local.parents,local.directory)){
			  ArrayAppend(local.nestedDirectories,local.directory);
			  ArrayAppend(local.directories,local.nestedDirectories);
			}
		}
		local.directories = ConvertDirectoryQueryToArray(query=arguments.query,parentId=local.row.Id,directories=local.directories,nestedDirectories=local.nestedDirectories,parents=local.parents);
	  }
	}
	
	return local.directories;

  }
  
  
  public any function CleanArray(array directories = ArrayNew(1), boolean formatWithKeys = false) output="true" {
	  
	  var local = {};
	  
	  local.directories = arguments.directories;
	  
	  local.temp = Duplicate(local.directories);
	  local.index = 1;
	
	  for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		if(IsArray(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
		  ArrayDelete(local.temp,local.directories[local.index]);
		}
	  }
	  
	  local.directories = local.temp;
	  
	  if(arguments.formatWithKeys){
		
		local.temp = ArrayNew(1);
		for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		  
		  if(IsSimpleValue(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
			local.struct = {};
			StructInsert(local.struct,local.directories[local.index],local.directories[local.index + 1]);
			ArrayAppend(local.temp,local.struct);
		  }
		  
		}
		local.directories = local.temp;
		
	  }
	  else{
		
		local.array = ArrayNew(1);
		  
		for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		  
		  if(IsSimpleValue(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
			local.temp = ArrayNew(1);
			ArrayAppend(local.temp,local.directories[local.index]);
			ArrayAppend(local.temp,local.directories[local.index + 1]);
			ArrayAppend(local.array,local.temp);
		  }
		  
		}
		
		local.directories = local.array;
		
	  }
	  
	  return local.directories;
  }
  
  
  public string function CapFirst(string str = "") output="true" {
	var local = {};
	if(Len(arguments.str) GT 1){
	  /*WriteOutput(arguments.str & "<br />");*/
	  local.string = Trim(UCase(Left(arguments.str,1)) & LCase(Right(arguments.str,Len(arguments.str)-1)));
	}
	else{
	  local.string = Trim(UCase(Left(arguments.str,1)));
	}
	return local.string;
  }
  
  
  public string function CapFirstAll(string str = "") output="true" {
	  
	var local = {};
	local.string = "";
	
	for(local.i = 1; local.i LTE ListLen(arguments.str," "); local.i = local.i + 1){
	  local.item = ListGetAt(arguments.str,local.i," ");
	  local.string = local.string & " " & CapFirst(local.item);
	}
	
	return local.string;
	
  }
  
  
  public string function FormatTitle(string str = "") output="true" {
	  
	var local = {};
	local.wordlist = "a,amid,an,and,anti,as,at,but,by,down,for,from,in,into,like,near,nor,of,off,on,onto,or,over,past,per,plus,so,than,the,to,up,upon,via,with,yet";
	local.wordlist = "a,aboard,about,above,across,after,against,ahead,along,amid,amidst,among,and,around,as,aside,at,athwart,atop,barring,because,before,behind,below,beneath,beside,besides,between,beyond,but,by,circa,concerning,despite,down,during,except,excluding,far,following,for,from,in,including,inside,into,like,minus,near,nor,notwithstanding,of,off,on,onto,opposite,or,out,outside,over,past,per,plus,prior,regarding,regardless,save,since,so,than,the,through,till,to,toward,towards,under,underneath,unlike,until,up,upon,versus,via,with,within,without,yet";
	
	local.string = CapFirstAll((Trim(arguments.str)));
	local.string = REReplaceNoCase(local.string,"[\s]+"," ","ALL");
	
	for(local.i = 1; local.i LTE ListLen(local.wordlist); local.i = local.i + 1){
	  local.string = ReplaceNoCase(local.string," " & ListGetAt(local.wordlist,local.i) & " "," " & ListGetAt(local.wordlist,local.i) & " ","ALL");
	}
		
	if(ListLen(local.string," ")){
	  local.string = ListSetAt(local.string,ListLen(local.string," "),CapFirst(ListGetAt(local.string,ListLen(local.string," ")," "))," ");
	  local.string = ListSetAt(local.string,1,CapFirst(ListGetAt(local.string,1," "))," ");
	}
	
	return local.string;
	
  }
  
  
</cfscript>