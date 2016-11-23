-module(mod).

-compile(export_all).

loop(Parent,List)->
	receive
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
		{exit} ->
			io:format("Server stopped ")
	end.
	
isPresent(_,[])-> false;

isPresent(Elem,[Head|Tail])->
	if 
		Elem==Head -> true;
		true -> isPresent(Elem,Tail)
	end.