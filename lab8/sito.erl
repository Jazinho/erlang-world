%%Proces glowny zapisuje w swojej tablicy wszystkie liczby pierwsze mniejsze od sqrt(n). Potem rozdziela na kolejne procesy kawalki tablicy liczb o stalej dlugosci ktore to sprawdzaja dla kazdego swojego elementu czy jest podzielny przez  ktorys z elementow podanej przez glowny proces tablicy bazowych liczb pierwszych.

%%--------PARALLEL---SIEVE---OF---ERATOSTENES-------------------
-module(sito).
-compile(export_all).
	
start(N) ->
	List = lists:seq(3,N,2),
	BasicPrimes = findPrimes([2]++lists:seq(3,round(math:sqrt(N)),2)),
	ListToCheck = lists:sublist(List,length(BasicPrimes)+1,length(List)-length(BasicPrimes)),
	spawnProcesses(BasicPrimes, ListToCheck).

spawnProcesses(BasicPrimes, ListToCheck) ->
	NumberOfProcessors = erlang:system_info(logical_processors_available),
	PartLen = round(length(ListToCheck)/NumberOfProcessors),
	Refs = spawnProcess(NumberOfProcessors, NumberOfProcessors, [], BasicPrimes, ListToCheck, PartLen),	
	BasicPrimes ++ collectResults(Refs).
	
spawnProcess(_, 0, ListOfRefs, _, _, _) -> ListOfRefs;
	
spawnProcess(NumberOfProcessors, Iter, ListOfRefs, BasicPrimes, ListToCheck, PartLen) ->
	Ref = make_ref(),
	spawn(?MODULE, filterPart, [self(), Ref, BasicPrimes, lists:sublist(ListToCheck, (NumberOfProcessors-Iter)*PartLen+1, PartLen)]),
	spawnProcess(NumberOfProcessors, Iter-1, ListOfRefs++[Ref], BasicPrimes, ListToCheck, PartLen).
	
collectResults([Ref|Tail]) ->
	receive
		{Ref, FoundPrimes} ->
			FoundPrimes ++ collectResults(Tail)
	end;

collectResults([]) -> [].

filterPart(Parent, Ref, BasicPrimes, ListToCheck) ->
	FoundPrimes = filter(ListToCheck, BasicPrimes, BasicPrimes, []),
	Parent ! {Ref, FoundPrimes}.
	
filter([H|L], [Prime|PrimesLeft], BasicPrimes, Result) ->
	if 
		H rem Prime == 0 ->
			filter(L,BasicPrimes,BasicPrimes, Result);
		true ->
			filter([H|L],PrimesLeft,BasicPrimes, Result)
	end;
	
filter([H|L], [], BasicPrimes, Result) ->
	NewResult = Result ++ [H],
	filter(L, BasicPrimes, BasicPrimes, NewResult);

filter([], _, _, Result) -> Result.
	
%-----FINDING BASIC PRIMES
	
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
