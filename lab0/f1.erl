-module(f1).
-export([function/1]).

function(N) -> N*4.

%Firstly, insert into erlang environment. Compile with: c(module_name). Execute with module_name:function_name(arguments).