-module(serw).

-compile(export_all).

init()->
	spawn(mod, loop, [self(),[]] ).

send(PID, Command, Arg) ->
	PID ! {Command, Arg},
	receive
		{Msg} -> io:format("~p \n",[Msg])
	end.

stop(PID) ->
	PID ! {exit},
	exit(PID,normal).
	
% To start server process: PID = serw:init()
% To send message to process: serw:send(PID, <command>, <command_arg>)
% To stop server process: serw:stop(PID)