%%Proces glowny zapisuje w swojej tablicy wszystkie liczby pierwsze mniejsze od sqrt(n). Potem rozdziela na kolejne procesy kawalki tablicy liczb o stalej dlugosci ktore to sprawdzaja dla kazdego swojego elementu czy jest podzielny przez  ktorys z elementow podanej przez glowny proces tablicy bazowych liczb pierwszych.

%%--------PARALLEL---SIEVE---OF---ERATOSTENES-------------------
-module(sito).
-compile(export_all).
	
start(N) ->
	if 
		is_integer(N) and (N > 2) -> 	
			List = lists:seq(3,N,2),
			BasicPrimes = findPrimes([2]++lists:seq(3,round(math:sqrt(N)),2)),
			ListToCheck = lists:sublist(List,length(BasicPrimes)+1,length(List)-length(BasicPrimes)),
			try spawnProcesses(BasicPrimes, ListToCheck)
			catch
				_:_ -> start(N)
			end;
		true ->
			io:format("Nalezy podac liczbe calkowita wieksza od 2~n")
	end.

spawnProcesses(BasicPrimes, ListToCheck) ->
	T1 = erlang:timestamp(),
	Length = length(ListToCheck),
	NumberOfThreads = erlang:system_info(logical_processors_available) * ((Length div 100000)+1),
	PartLen = round(Length/NumberOfThreads),
	Refs = spawnProcess(NumberOfThreads, NumberOfThreads, [], BasicPrimes, ListToCheck, PartLen),
	T2 = erlang:timestamp(),
	io:format("Obliczenia trwaly ~p mikrosekund~n",[timer:now_diff(T2,T1)]),
	BasicPrimes ++ collectResults(Refs).
	
spawnProcess(_, 0, ListOfRefs, _, _, _) -> ListOfRefs;
	
spawnProcess(NumberOfThreads, Iter, ListOfRefs, BasicPrimes, ListToCheck, PartLen) ->
	Ref = make_ref(),
	spawn_link(?MODULE, filterPart, [self(), Ref, BasicPrimes, lists:sublist(ListToCheck, (NumberOfThreads-Iter)*PartLen+1, PartLen)]),
	spawnProcess(NumberOfThreads, Iter-1, ListOfRefs++[Ref], BasicPrimes, ListToCheck, PartLen).
	
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
