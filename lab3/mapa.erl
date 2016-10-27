-module(mapa).

-compile(export_all).

start(List, Function) -> procMap(List, Function, []).

wrapper(Parent, Function, Arg, RefTag) ->
	Parent ! {Function(Arg),RefTag}.

procMap([Head|Tail], Function, ListOfTags) ->
	RefTag = make_ref(),
	spawn(?MODULE, wrapper, [self(), Function, Head, RefTag]),
	procMap(Tail, Function, ListOfTags ++ [RefTag]);
	
procMap([], _, ListOfTags) -> collectResults(ListOfTags).

collectResults([HeadTag | Tail]) ->
	receive 
		{Result, HeadTag} -> 
			[Result] ++ collectResults(Tail)
	end;

collectResults([]) -> [].
