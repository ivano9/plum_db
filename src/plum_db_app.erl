%% =============================================================================
%%  plum_db_app.erl -
%%
%%  Copyright (c) 2018-2019 Ngineo Limited t/a Leapsight. All rights reserved.
%%
%%  Licensed under the Apache License, Version 2.0 (the "License");
%%  you may not use this file except in compliance with the License.
%%  You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%%  Unless required by applicable law or agreed to in writing, software
%%  distributed under the License is distributed on an "AS IS" BASIS,
%%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%  See the License for the specific language governing permissions and
%%  limitations under the License.
%% =============================================================================

%% -----------------------------------------------------------------------------
%% @doc
%%
%% ```
%%                         +------------------+
%%                         |                  |
%%                         |   plum_db_sup    |
%%                         |                  |
%%                         +------------------+
%%                                   |
%%           +-----------------------+-----------------------+
%%           |                       |                       |
%%           v                       v                       v
%% +------------------+    +------------------+    +------------------+
%% |                  |    |     plum_db_     |    |                  |
%% |     plum_db      |    |  partitions_sup  |    |  plum_db_events  |
%% |                  |    |                  |    |                  |
%% +------------------+    +------------------+    +------------------+
%%                                   |
%%                       +-----------+-----------+
%%                       |                       |
%%                       v                       v
%%             +------------------+    +------------------+
%%             |plum_db_partition_|    |plum_db_partition_|
%%             |      1_sup       |    |      n_sup       |
%%             |                  |    |                  |
%%             +------------------+    +------------------+
%%                       |
%%           +-----------+-----------+----------------------+
%%           |                       |                      |
%%           v                       v                      v
%% +------------------+    +------------------+   +------------------+
%% |plum_db_partition_|    |plum_db_partition_|   |plum_db_partition_|
%% |     1_worker     |    |     1_server     |   |    1_hashtree    |
%% |                  |    |                  |   |                  |
%% +------------------+    +------------------+   +------------------+
%%                                   |                      |
%%                                   v                      v
%%                         + - - - - - - - - -    + - - - - - - - - -
%%                                            |                      |
%%                         |     eleveldb         |     eleveldb
%%                                            |                      |
%%                         + - - - - - - - - -    + - - - - - - - - -
%% '''
%%
%% @end
%% -----------------------------------------------------------------------------
-module(plum_db_app).
-behaviour(application).

-export([start/2]).
-export([start_phase/3]).
-export([prep_stop/1]).
-export([stop/1]).



%% =============================================================================
%% API
%% =============================================================================



%% -----------------------------------------------------------------------------
%% @doc
%% @end
%% -----------------------------------------------------------------------------
start(_StartType, _StartArgs) ->
    %% It is important we init the config before starting the supervisor
    %% as we override some user configuration for both partisan and plumtree
    %% before they start (they are included applications and our supervisor
    %% starts them).
    ok = plum_db_config:init(),

    case plum_db_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            Other
    end.


%% -----------------------------------------------------------------------------
%% @doc Application behaviour callback
%% @end
%% -----------------------------------------------------------------------------
start_phase(init_db_partitions, normal, []) ->
    WaitForPartitions = plum_db_config:get(wait_for_partitions),
    WaitForHashtrees = plum_db_config:get(aae_enabled)
        andalso plum_db_config:get(wait_for_hashtrees),
    %% Waiting for hasstrees implies also waiting for partitions
    case WaitForPartitions orelse WaitForHashtrees of
        true ->
            %% We block until all partitions are initialised
            plum_db_startup_coordinator:wait_for_partitions();
        false ->
            ok
    end;

start_phase(init_db_hashtrees, normal, []) ->
    WaitForHashtrees = plum_db_config:get(aae_enabled)
        andalso plum_db_config:get(wait_for_hashtrees),
    case WaitForHashtrees of
        true ->
            %% We block until all hashtrees are built
            plum_db_startup_coordinator:wait_for_hashtrees();
        false ->
            ok
    end,
    plum_db_startup_coordinator:stop().


%% -----------------------------------------------------------------------------
%% @doc
%% @end
%% -----------------------------------------------------------------------------
prep_stop(_State) ->
    ok.


%% -----------------------------------------------------------------------------
%% @doc
%% @end
%% -----------------------------------------------------------------------------
stop(_State) ->
    ok.
