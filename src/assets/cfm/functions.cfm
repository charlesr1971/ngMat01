<cfscript>

  public query function ParseDirectory(required string path) output="true" {
	  
	var local = {};
	
	var aQuery = "";
	  		
	cfdirectory(action="list",directory=arguments.path,name="local.query1",sort="Directory, Name ASC",type="all",recurse="yes");

	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query1);
	local.objQueryResult = local.queryService.execute(sql="SELECT Directory, Name FROM sourceQuery");
	local.queryResult1 = local.objQueryResult.getResult();
	
	local.query2 = QueryNew("Id,ParentId,Directory,Name");	
	
	if(local.queryResult1.RecordCount){
	  for(local.row in local.queryResult1){
		QueryAddRow(local.query2);
		QuerySetCell(local.query2,"Id",local.queryResult1.CurrentRow);
		QuerySetCell(local.query2,"ParentId","");
		QuerySetCell(local.query2,"Directory",local.row.Directory);
		QuerySetCell(local.query2,"Name",local.row.Name);
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
		  }
		}
	  }
	}
	
	//WriteDump(var=local.query2);
	
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
		//['Fruits', ['Apple', 'Orange', 'Banana']],
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
			//local.struct[local.directories[local.index]] = local.directories[local.index + 1];
			ArrayAppend(local.temp,local.struct);
		  }
		  
		}
		local.directories = local.temp;
		
	  }
	  else{
		  
		/*local.temp = ArrayNew(1);
		ArrayAppend(local.temp,local.directories);
		local.directories = local.temp;*/
		
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
	  
	  //WriteDump(var=local.directories);

	  return local.directories;
  }
  
</cfscript>