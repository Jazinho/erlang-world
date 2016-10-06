-module(lab0).
-export([area/1,len/1, amin/1, amax/1, tuple_min_max/1, list_min_max/1, pola/1, prog/1, lista_jedynek/1, lista_znakow/2, convTemp/2]).
-compile({no_auto_import,[len/1]}).

% Ex.1 - calculating polygons' areas
area({rect,X,Y}) ->X*Y;
area({cir,X}) -> 3.14*X*X;
area({triangle, A, B, C}) -> P=(A+B+C)/2, math:sqrt(P*(P-A)*(P-B)*(P-C));
area({trapeze, A, B, H}) -> (A+B)/2*H;
area({cuboid, A, B, C}) -> 2*area({rect,A,B})+2*area({rect,B,C})+2*area({rect,A,C}).

% Ex.2 - calculating list's length
len([]) -> 0;
len([_|Tail]) -> 1+ len(Tail).

%Ex.3 - finding minimum element of list
amin([]) -> false;
amin([Head|Tail]) -> mini(Head, Tail).

mini(Min, []) -> Min;
mini(Min,[Head|Tail]) ->
	case Head < Min of
		true ->	mini(Head, Tail);
		false -> mini(Min, Tail)
	end.
	
% Ex.4 - finding maximum element of list
amax([]) -> false;
amax([Head|Tail]) -> maxi(Head,Tail).

maxi(Max,[])-> Max;
maxi(Max,[Head|Tail])->
	case Max<Head of
		true -> maxi(Head,Tail);
		false -> maxi(Max,Tail)
	end.
	
% Ex.5 - returning tuple containing minimum and maximum element of list
tuple_min_max(List) -> {amin(List), amax(List)}.

% Ex.6 - returning list containing minimum and maximum element of list
list_min_max(List) -> [amin(List),amax(List)].

% Ex.7 - returning array of fields of polygons given in list of tuples
pola([]) -> [];
pola([Head]) -> [area(Head)];
pola([Head|Tail]) -> [area(Head)]++pola(Tail).

% Ex.8 - returning list in form [N,N-1,N-2,...,2,1]
prog(0) -> [];
prog(N) -> [N]++prog(N-1).

% Ex.9 - temperature converter (temperature given in tuples {type, value}, ex. {c, 20.5}; function gets temperature and scale to convert).
convTemp(Tuple, ScaleTo) -> 
	C= toCelc(Tuple, ScaleTo),
	case ScaleTo of
		c -> C;
		f -> (9/5) * C + 32;
		k -> C + 273.15
	end.

toCelc({ScaleFrom, Value}, _) ->
	case ScaleFrom of
		f -> (5/9) * (Value-32);
		k -> Value - 273.15;
		c -> Value
	end.


% Ex.10 - returning array of ones of specified length/array of specified signs of specified length
lista_jedynek(0) -> [];
lista_jedynek(Length) -> [1]++lista_jedynek(Length-1).

lista_znakow(0, _) -> [];
lista_znakow(Length, Znak) -> [Znak]++lista_znakow(Length-1, Znak).
