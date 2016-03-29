-module(templaterl_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link([Templaterl]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Templaterl]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Templaterl]) ->
    {ok, {{one_for_one, 5, 10}, [
        ?CHILD(executor, Templaterl)
    ]}}.