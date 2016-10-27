-module(mapa).

-compile(export_all).

wrapper(Parent, Function, Arg) ->
	Parent ! Function(Arg).

procMap([Head|Tail], Function) ->
	%RefTag = make_ref(),
	spawn(?MODULE, wrapper, [self(), Function, Head]),
	procMap(Tail, Function);
	
procMap([], _) -> collectResults().

collectResults() ->
	receive 
		Result -> 
			[Result] ++ collectResults()
	after 200 ->
			[]
	end.


%% TODO:: zwracane wyniki mogą byc nie po kolei - uzyc mk_ref())