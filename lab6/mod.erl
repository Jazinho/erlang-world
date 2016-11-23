-module(mod).

-compile(export_all).

loop(Parent,List)->
	receive
		saveState ->
			R = io_lib:format("~p",[self()]),
			lists:flatten(R),
			String=lists:nth(1,R),
			Filename= string:substr(String,2,length(String)-2)++".txt",
			{ok,FD} = file:open(Filename,[write]),
			
			S = io_lib:format("~p", [List] ),
			lists:flatten(S),
			StringList = lists:nth(1,S),
			file:write(FD, StringList),
			file:close(FD),
			Parent ! {savedState},
			loop(Parent,List);

		{recreateState,PID} ->
			R = io_lib:format("~p",[PID]),
			lists:flatten(R),
			String=lists:nth(1,R),
			Filename= string:substr(String,2,length(String)-2)++".txt",
			case filelib:is_file(Filename) of
				true -> 
					{ok,FD} = file:open(Filename,[read]),
					{ok, Content} = file:read_line(FD),
					StringList = string:substr(Content,2,string:len(Content)-2),
					io:format(StringList),
					StringStatesList = string:tokens(StringList, ","),
					StatesList = lists:map(fun(X)->list_to_atom(X) end,StringStatesList),
					Parent ! {recreated_state},
					loop(Parent,StatesList);
				false -> 
					Parent ! {state_for_PID_not_found},
					loop(Parent,List)
			end;
			
		{store, Name} -> 
			Parent ! {stored},
			loop(Parent,[Name|List]);
			
		{delete, Name} -> 
			case isPresent(Name,List) of
				true ->
					Parent ! {deleted},
					loop(Parent,lists:delete(Name,List));
				false ->
					Parent ! {not_found},
					loop(Parent,List)
			end;
			
		{isPresent, Name} ->
			case isPresent(Name,List) of
				true ->
					Parent ! {found},
					loop(Parent,List);
				false ->
					Parent ! {not_found},
					loop(Parent, List)
			end;
			
		_ ->
			io:format("Server stopped ")
	end.
	
isPresent(_,[])-> false;

isPresent(Elem,[Head|Tail])->
	if 
		Elem==Head -> true;
		true -> isPresent(Elem,Tail)
	end.