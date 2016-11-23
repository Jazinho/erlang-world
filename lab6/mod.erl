-module(mod).

-compile(export_all).

loop(Parent,List)->
	receive
		{store, Name} -> 
			R = io_lib:format("~p",[self()]),
			lists:flatten(R),
			String=lists:nth(1,R),
			Filename= string:substr(String,2,length(String)-2)++".txt",
			{ok,FD} = file:open(Filename,[write]),
			
			S = io_lib:format("~p", [lists:append([Name],List)] ),
			lists:flatten(S),
			StringName = lists:nth(1,S),
			file:write(FD, StringName),
			file:close(FD),
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