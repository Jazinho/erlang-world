-module(temperature).

-compile(export_all).

convTemp(Tuple, ScaleTo) -> 
	C= toCelc(Tuple, ScaleTo),
	case ScaleTo of
		"c" -> {ScaleTo, C };
		"f" -> {ScaleTo, (9/5) * C + 32 };
		"k" -> {ScaleTo, C + 273.15}
	end.

toCelc({ScaleFrom, Value}, _) ->
	case ScaleFrom of
		"f" -> (5/9) * (Value-32);
		"k" -> Value - 273.15;
		"c" -> Value
	end.
	
getInput(Parent) ->
	receive
		{ScaleFrom, Temperature, ScaleTo} -> 
			{_,Result} = convTemp({ScaleFrom, Temperature}, ScaleTo),
			Parent ! Result;
		_ ->
			io:fwrite("Sth went wrong")
	end.

%Version that convert every input temperature in another process
			
converter() ->
	Scale = io:get_chars("Give me basic scale: c - Celsius, f - Fahrenheit, k - Kelvin >",1),
	{ok,List}= io:fread("Give me temperature value (as floating number) >","~f"),
	Temp = lists:nth(1,List),
	DestScale = io:get_chars("Give me desired scale >",1),

	F = spawn(?MODULE, getInput, [self()]),
	F ! {Scale,Temp,DestScale},
	receive
		Result ->
			io:format("Result is "),
			io:format("~.2f~n", [Result])
	end,
	converter().

%Version that convert every input temperature in one another process

start_converting()->
	P = spawn(?MODULE, getInput, [self()]),
	get_data(P).


get_data(PID)->
	Scale = io:get_chars("Give me basic scale: c - Celsius, f - Fahrenheit, k - Kelvin >",1),
	{ok,List}= io:fread("Give me temperature value (as floating number) >","~f"),
	Temp = lists:nth(1,List),
	DestScale = io:get_chars("Give me desired scale >",1),

	PID ! {Scale, lists:nth(1,List), DestScale},

	receive
		Result ->
			io:format("Result is "),
			io:format("~.2f~n", [Result])
	end,
	get_data(PID).	
