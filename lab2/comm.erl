-module(comm).

-compile(export_all).

%%------------------------------------------------------
%% basic function that answers with the same message as received

func() ->
	receive
		{PID,Msg} -> PID ! Msg
	end.
	
%%to execute:  F=spawn(fun comm:func/0).  and then:  F ! {self(),"Message to process"}.
