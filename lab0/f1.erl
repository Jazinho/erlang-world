-module(f1).
-export([function/1]).

function(N) -> N*4.

%Firstly, insert into erlang environment. Compile with: c(module_name). Execute with module_name:function_name(arguments).

% tricky Erlang stuff: 
% in compiler type '[65,66,67,68,69].'.
% It should print the same: list of numbers.
% IT SHOULD. But....