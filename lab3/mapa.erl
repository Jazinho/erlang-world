-module(mapa).

-compile(export_all).


exFunction(Parent, Arg) ->
	Parent ! {Arg*3}.

procMap([]) -> [];

procMap([Head|Tail]) ->
	RefTag = make_ref(),
	spawn(?MODULE, exFunction, [self(), Head]),
	procMap(Tail) ++
	receive
		{Result} -> [Result]
	end.
	
start(List) ->
	lists:reverse(procMap(List)).



%%mapa ronwoległa (zwracane wyniki mogą byc nie po kolei - uzyc mk_ref())

% Jakby chcieć brać funkcje od użytkownika to jak wywołać spawn (w wersji 1 argumentowej nie ma jak podać parametrów, a w wersji 3 argumentowej nie wiadomo jaki moduł)

% Czy obecna wersja jest współbieżna (Jakby powywoływać spawna dla każdego argumentu i w każdym byłoby receive to jak to potem połączyć z powrotem do kupy?)
