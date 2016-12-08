%%dla 1000 liczb.
%%Proces glowny zapisuje w swojej tablicy wszystkie liczby pierwsze mniejsze od sqrt(n). Potem %%rozdziela na kolejne procesy kawalki stalej dlugosci ktore to checkaja dla azdego swojego %%elementu czy jest podzielny przez  ktorys z elementow podanej przez glowny proces tablicy.

%%--------PARALLEL---SIEVE---OF---ERATOSTENES-------------------
-module(sito).
-compile(export_all).
 
start(N) ->
	List = [2]++lists:seq(3,round(math:sqrt(N)),2),
	findPrimes(List).
	
findPrimes(List) ->
	check(List,[],[]).

check([],_,Res) -> Res;

check([H|L],_,[]) ->
	check(L,[H],[H]);
	
check([H|L],[Checked|CheckedTail],Result) ->
	if 
		H rem Checked == 0 ->
			check(L,Result,Result);
		true ->
			check([H|L],CheckedTail,Result)
	end;
	
check([H|L], [], Result) ->
	NewRes = Result ++ [H],
	check(L, NewRes, NewRes).
	
	
	