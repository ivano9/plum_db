%% =============================================================================
%%  plum_db_rocksdb_metrics_collector.erl -
%%
%%  Copyright (c) 2017-2025 Leapsight. All rights reserved.
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

-module(plum_db_rocksdb_metrics_collector).

-behaviour(gen_server).

-include_lib("kernel/include/logger.hrl").

-moduledoc """

```
telemetry:attach(
  rocksdb_debug_logger,
  [plum_db, rocksdb, metrics],
  fun(EventName, Measurements, Metadata, _Config) ->
      io:format("~p ~p ~p~n", [EventName, Measurements, Metadata])
  end,
  ok).
```
""".

%% API

-export([start_link/1]).
-export([start_link/2]).
-export([stop/1]).
-export([all_stats/0]).
-export([all_metrics/0]).
-export([get_metrics/1]).
-export([get_metrics/2]).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(DEFAULT_INTERVAL_MS, timer:seconds(10)).

-record(state, {
    interval_ms :: non_neg_integer(),
    metrics     :: [map()],
    timer_ref   :: reference() | undefined
}).



%% =============================================================================
%% API
%% =============================================================================



-spec start_link(map()) -> {ok, pid()} | {error, term()}.
start_link(Opts) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, Opts, []).


-spec start_link(atom(), map()) -> {ok, pid()} | {error, term()}.
start_link(Name, Opts) ->
    gen_server:start_link({local, Name}, ?MODULE, Opts, []).


-spec stop(pid() | atom()) -> ok.
stop(Server) ->
    gen_server:call(Server, stop).



%%%-------------------------------------------------------------------
%%% Default metrics: one entry per known RocksDB property constant.
%%% See: rocksdb::properties (Rust) which mirrors include/rocksdb/db.h
%%%-------------------------------------------------------------------

all_metrics() ->
    [
        %% Rate / throttling
        #{
            name => actual_delayed_write_rate,
            prop => <<"rocksdb.actual-delayed-write-rate">>,
            kind => int
        },

        %% Background errors
        #{
            name => background_errors,
            prop => <<"rocksdb.background-errors">>,
            kind => int
        },

        %% Base level
        #{
            name => base_level,
            prop => <<"rocksdb.base-level">>,
            kind => int
        },

        %% Block cache stats
        #{
            name => block_cache_capacity,
            prop => <<"rocksdb.block-cache-capacity">>,
            kind => int
        },
        #{
            name => block_cache_pinned_usage,
            prop => <<"rocksdb.block-cache-pinned-usage">>,
            kind => int
        },
        #{
            name => block_cache_usage,
            prop => <<"rocksdb.block-cache-usage">>,
            kind => int
        },



        %% Compaction pending flag
        #{
            name => compaction_pending,
            prop => <<"rocksdb.compaction-pending">>,
            kind => int
        },

        %% LSM version
        #{
            name => current_super_version_number,
            prop => <<"rocksdb.current-super-version-number">>,
            kind => int
        },

        %% Memtable sizes
        #{
            name => cur_size_active_mem_table,
            prop => <<"rocksdb.cur-size-active-mem-table">>,
            kind => int
        },
        #{
            name => cur_size_all_mem_tables,
            prop => <<"rocksdb.cur-size-all-mem-tables">>,
            kind => int
        },
        #{
            name => size_all_mem_tables,
            prop => <<"rocksdb.size-all-mem-tables">>,
            kind => int
        },

        %% Live data / key estimates
        #{
            name => estimate_live_data_size,
            prop => <<"rocksdb.estimate-live-data-size">>,
            kind => int
        },
        #{
            name => estimate_num_keys,
            prop => <<"rocksdb.estimate-num-keys">>,
            kind => int
        },
        #{
            name => estimate_pending_compaction_bytes,
            prop => <<"rocksdb.estimate-pending-compaction-bytes">>,
            kind => int
        },
        #{
            name => estimate_table_readers_mem,
            prop => <<"rocksdb.estimate-table-readers-mem">>,
            kind => int
        },

        %% File deletion / write stop flags
        #{
            name => is_file_deletions_enabled,
            prop => <<"rocksdb.is-file-deletions-enabled">>,
            kind => int
        },
        #{
            name => is_write_stopped,
            prop => <<"rocksdb.is-write-stopped">>,
            kind => int
        },


        %% SST sizes
        #{
            name => live_sst_files_size,
            prop => <<"rocksdb.live-sst-files-size">>,
            kind => int
        },
        #{
            name => total_sst_files_size,
            prop => <<"rocksdb.total-sst-files-size">>,
            kind => int
        },

        %% Flush / memtable flags
        #{
            name => mem_table_flush_pending,
            prop => <<"rocksdb.mem-table-flush-pending">>,
            kind => int
        },

        %% WAL & obsolete SST retention
        #{
            name => min_log_number_to_keep,
            prop => <<"rocksdb.min-log-number-to-keep">>,
            kind => int
        },
        #{
            name => min_obsolete_sst_number_to_keep,
            prop => <<"rocksdb.min-obsolete-sst-number-to-keep">>,
            kind => int
        },

        %% Memtable entry / delete counts
        #{
            name => num_deletes_active_mem_table,
            prop => <<"rocksdb.num-deletes-active-mem-table">>,
            kind => int
        },
        #{
            name => num_deletes_imm_mem_tables,
            prop => <<"rocksdb.num-deletes-imm-mem-tables">>,
            kind => int
        },
        #{
            name => num_entries_active_mem_table,
            prop => <<"rocksdb.num-entries-active-mem-table">>,
            kind => int
        },
        #{
            name => num_entries_imm_mem_tables,
            prop => <<"rocksdb.num-entries-imm-mem-tables">>,
            kind => int
        },

        %% Immutable memtables
        #{
            name => num_immutable_mem_table,
            prop => <<"rocksdb.num-immutable-mem-table">>,
            kind => int
        },
        #{
            name => num_immutable_mem_table_flushed,
            prop => <<"rocksdb.num-immutable-mem-table-flushed">>,
            kind => int
        },

        %% Versions / running ops
        #{
            name => num_live_versions,
            prop => <<"rocksdb.num-live-versions">>,
            kind => int
        },
        #{
            name => num_running_compactions,
            prop => <<"rocksdb.num-running-compactions">>,
            kind => int
        },
        #{
            name => num_running_flushes,
            prop => <<"rocksdb.num-running-flushes">>,
            kind => int
        },

        %% Snapshots
        #{
            name => num_snapshots,
            prop => <<"rocksdb.num-snapshots">>,
            kind => int
        },
        #{
            name => oldest_snapshot_time,
            prop => <<"rocksdb.oldest-snapshot-time">>,
            kind => int
        }
    ].

all_stats() ->
    [
         %% DB-level stats (multi-line)
        %% #{
        %%     name => dbstats,
        %%     prop => <<"rocksdb.dbstats">>,
        %%     kind => string
        %% },

        %% Column family stats (multi-line)
        #{
            name => cfstats,
            prop => <<"rocksdb.cfstats">>,
            kind => string
        },
        #{
            name => cfstats_no_file_histogram,
            prop => <<"rocksdb.cfstats-no-file-histogram">>,
            kind => string
        },
        #{
            name => cf_file_histogram,
            prop => <<"rocksdb.cf-file-histogram">>,
            kind => string
        },

        %% Per-level overview (multi-line)
        #{
            name => levelstats,
            prop => <<"rocksdb.levelstats">>,
            kind => string
        },


        %% Aggregated table properties (string)
        #{
            name => aggregated_table_properties,
            prop => <<"rocksdb.aggregated-table-properties">>,
            kind => string
        },

        %% Options statistics (multi-line)
        #{
            name => options_statistics,
            prop => <<"rocksdb.options-statistics">>,
            kind => string
        },

        %% SST summary (multi-line)
        #{
            name => sstables,
            prop => <<"rocksdb.sstables">>,
            kind => string
        },

        %% Combined stats (multi-line)
        #{
            name => stats,
            prop => <<"rocksdb.stats">>,
            kind => string
        }
    ].

get_metrics(DbRef) ->
    get_metrics(DbRef, all_metrics()).


get_metrics(DbRef, Metrics) ->
    lists:foldl(
        fun(#{name := Name, prop := Prop, kind := Kind}, Acc) ->
            try
                case rocksdb:get_property(DbRef, Prop) of
                    {ok, ValBin} ->
                        case parse_metric_value(ValBin, Kind) of
                            {ok, Value} ->
                                maps:put(Name, Value, Acc);

                            {error, _Reason} ->
                                Acc
                        end;
                    {error, _Reason} ->
                        Acc
                end
            catch
                _:_ ->
                    ?LOG_WARNING(#{
                        description => "Fail to retrieve RocksDB property",
                        property => Prop
                    }),
                    Acc
            end
        end,
        #{},
        Metrics
    ).


%% =============================================================================
%% GEN_SERVER CALLBACKS
%% =============================================================================



init(Opts) ->
    Interval = maps:get(interval_ms, Opts, ?DEFAULT_INTERVAL_MS),
    Metrics = maps:get(metrics, Opts, all_metrics()),

    State0 = #state{
        interval_ms = Interval,
        metrics = Metrics,
        timer_ref = undefined
    },

    {ok, schedule_collect(State0)}.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};

handle_call(_Req, _From, State) ->
    {reply, {error, unknown_call}, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info(collect, State0 = #state{}) ->
    State1 = State0#state{timer_ref = undefined},
    safe_collect(State1),
    {noreply, schedule_collect(State1)};

handle_info(_Other, State) ->
    {noreply, State}.

terminate(_Reason, #state{timer_ref = Ref}) ->
    case Ref of
        R when is_reference(R) ->
            erlang:cancel_timer(R),
            ok;

        _ ->
            ok
    end.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.




%% =============================================================================
%% PRIVATE
%% =============================================================================



schedule_collect(State = #state{interval_ms = Interval}) ->
    Ref = erlang:send_after(Interval, self(), collect),
    State#state{timer_ref = Ref}.

safe_collect(State) ->
    try collect(State) of
        ok ->
            ok
    catch
        Class:Reason:Stacktrace ->
            ?LOG_ERROR(#{
                description => "Failed to collect metrics",
                class => Class,
                reason => Reason,
                stacktrace => Stacktrace
            })
    end.

collect(#state{metrics = Metrics}) ->
    lists:foreach(
        fun(Partition) ->
            execute(plum_db_partition_server, Partition, Metrics)
        end,
      plum_db:partitions()
    ),
    ok.


execute(Mod, Partition, Metrics) ->
    try
        DbRef = Mod:get_db_ref(Partition),
        telemetry:execute(
            [plum_db, rocksdb, metrics],
            get_metrics(DbRef, Metrics),
            #{
                partition => Partition,
                type => Mod
            }
        )
    catch
        error:Reason ->
            ?LOG_ERROR(#{
                description => "Failed to collect metrics",
                reason => Reason,
                partition => Partition
            }),
            ok
    end.



parse_metric_value(ValBin, int) when is_binary(ValBin) ->
    case catch binary_to_integer(ValBin) of
        Int when is_integer(Int) ->
            {ok, Int};
        _ ->
            {error, bad_int}
    end;

parse_metric_value(ValBin, float) when is_binary(ValBin) ->
    case catch binary_to_float(ValBin) of
        F when is_float(F) ->
            {ok, F};
        _ ->
            %% Try integer and cast to float
            case catch binary_to_integer(ValBin) of
                Int when is_integer(Int) ->
                    {ok, 1.0 * Int};
                _ ->
                    {error, bad_float}
            end
    end;

parse_metric_value(ValBin, string) when is_binary(ValBin) ->
    {ok, ValBin}.