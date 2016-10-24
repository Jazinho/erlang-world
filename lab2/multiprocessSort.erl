-module(multiprocessSort).
-import(rand,[uniform/1]).

-compile(export_all).

initArray() -> [rand:uniform(15) || _ <- lists:seq(1, 11)].

sort(Parent, L) ->
	case length(L)>2 of
		true->
			{One,Two} = lists:split(round( length(L)/2 ), L),
			P1 = spawn(?MODULE, sort, [self(),One]),
			P2 = spawn(?MODULE, sort, [self(),Two]),
			receive
				{PID1, List1} -> 
					receive
						{PID2, List2} -> 
							Parent ! {self(), lists:merge(List1,List2)}
					end
			end;
		false ->
			Parent ! {self(),lists:sort(L)}
	end.

posortuj(Parent, [X1,X2]) ->
	case X1<X2 of
		true -> Parent ! {self(),[X2,X1]};
		false-> Parent ! {self(),[X1,X2]}
	end.