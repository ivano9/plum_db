%% -----------------------------------------------------------------------------
%% @doc
%%
%% <pre><code>
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
%% </code></pre>
%%
%% @end
%% -----------------------------------------------------------------------------
-module(plum_db_app).
-behaviour(application).

-export([start/2]).
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
    ok = plum_db_config:init(),
    case plum_db_sup:start_link() of
        {ok, Pid} ->
            %% We set the pubsub handler
            ok = plum_db_events:add_pubsub_handler(),
            ok = setup_partisan(),
            {ok, Pid};
        Other ->
            Other
    end.


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





%% =============================================================================
%% PRIVATE
%% =============================================================================


%% @private
setup_partisan() ->
    Channels0 = partisan_config:get(channels, []),
    partisan_config:set(channels, [aae_messages | Channels0]).
