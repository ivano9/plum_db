%% -------------------------------------------------------------------
%%
%% Copyright (c) 2012 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc
%% This module implements a persistent, on-disk hash tree that is used
%% predominately for active anti-entropy exchange in Riak. The tree consists
%% of two parts, a set of unbounded on-disk segments and a fixed size hash
%% tree (that may be on-disk or in-memory) constructed over these segments.
%%
%% Each segment logically represents an on-disk list of (key, hash) pairs.
%% Whereas the hash tree is represented as a set of levels and buckets, with a
%% fixed width (or fan-out) between levels that determines how many buckets of
%% a child level are grouped together and hashed to represent a bucket at the
%% parent level. Each leaf in the tree corresponds to a hash of one of the
%% on-disk segments. For example, a tree with a width of 4 and 16 segments
%% would look like the following:
%%
%% The following diagram is a graphical depiction of this design.
%%
%% <pre><code class="mermaid">
%% %%{init: {'theme': 'neutral' } }%%
%% graph TD
%%   r[" "]
%%
%%   a[" "]; b[" "]; c[" "]; d[" "]
%%
%%   a1[" "]; a2[" "]; a3[" "]; a4[" "];
%%   a11[" "]; a12[" "]; a13[" "]; a14[" "]; a15[" "]; a16[" "];
%%   a21[" "]; a22[" "]; a23[" "]; a24[" "]; a25[" "]; a26[" "];
%%   a31[" "]; a32[" "]; a33[" "]; a34[" "]; a35[" "]; a36[" "];
%%   a41[" "]; a42[" "]; a43[" "]; a44[" "]; a45[" "]; a46[" "];
%%
%%   b1[" "]; b2[" "]; b3[" "]; b4[" "];
%%   b11[" "]; b12[" "]; b13[" "]; b14[" "]; b15[" "]; b16[" "];
%%   b21[" "]; b22[" "]; b23[" "]; b24[" "]; b25[" "]; b26[" "];
%%   b31[" "]; b32[" "]; b33[" "]; b34[" "]; b35[" "]; b36[" "];
%%   b41[" "]; b42[" "]; b43[" "]; b44[" "]; b45[" "]; b46[" "];
%%
%%   c1[" "]; c2[" "]; c3[" "]; c4[" "];
%%   c11[" "]; c12[" "]; c13[" "]; c14[" "]; c15[" "]; c16[" "];
%%   c21[" "]; c22[" "]; c23[" "]; c24[" "]; c25[" "]; c26[" "];
%%   c31[" "]; c32[" "]; c33[" "]; c34[" "]; c35[" "]; c36[" "];
%%   c41[" "]; c42[" "]; c43[" "]; c44[" "]; c45[" "]; c46[" "];
%%
%%   d1[" "]; d2[" "]; d3[" "]; d4[" "];
%%   d11[" "]; d12[" "]; d13[" "]; d14[" "]; d15[" "]; d16[" "];
%%   d21[" "]; d22[" "]; d23[" "]; d24[" "]; d25[" "]; d26[" "];
%%   d31[" "]; d32[" "]; d33[" "]; d34[" "]; d35[" "]; d36[" "];
%%   d41[" "]; d42[" "]; d43[" "]; d44[" "]; d45[" "]; d46[" "];
%%
%%   subgraph " "
%%   a; b; c; d
%%   end
%%
%%   r --> a; r --> b; r --> c; r --> d
%%
%%   subgraph A [" "]
%%   a2; a2; a3; a4
%%   end
%%
%%   subgraph A1 [" "]
%%   a11; a12; a13; a14; a15; a16
%%   end
%%   subgraph A2 [" "]
%%   a21; a22; a23; a24; a25; a26
%%   end
%%   subgraph A3 [" "]
%%   a31; a32; a33; a34; a35; a36
%%   end
%%   subgraph A4 [" "]
%%   a41; a42; a43; a44; a45; a46
%%   end
%%
%%   a --> a1; a --> a2; a --> a3; a --> a4
%%   a1 --- a11 --- a12 --- a13 --- a14 --- a15 --- a16
%%   a2 --- a21 --- a22 --- a23 --- a24 --- a25 --- a26
%%   a3 --- a31 --- a32 --- a33 --- a34 --- a35 --- a36
%%   a4 --- a41 --- a42 --- a43 --- a44 --- a45 --- a46
%%
%%   subgraph B [" "]
%%   b1; b2; b3; b4
%%   end
%%
%%   subgraph B1 [" "]
%%   b11; b12; b13; b14; b15; b16
%%   end
%%   subgraph B2 [" "]
%%   b21; b22; b23; b24; b25; b26
%%   end
%%   subgraph B3 [" "]
%%   b31; b32; b33; b34; b35; b36
%%   end
%%   subgraph B4 [" "]
%%   b41; b42; b43; b44; b45; b46
%%   end
%%
%%   b --> b1; b --> b2; b --> b3; b --> b4
%%   b1 --- b11 --- b12 --- b13 --- b14 --- b15 --- b16
%%   b2 --- b21 --- b22 --- b23 --- b24 --- b25 --- b26
%%   b3 --- b31 --- b32 --- b33 --- b34 --- b35 --- b36
%%   b4 --- b41 --- b42 --- b43 --- b44 --- b45 --- b46
%%
%%   subgraph C [" "]
%%   c1; c2; c3; c4
%%   end
%%
%%   subgraph C1 [" "]
%%   c11; c12; c13; c14; c15; c16
%%   end
%%   subgraph C2 [" "]
%%   c21; c22; c23; c24; c25; c26
%%   end
%%   subgraph C3 [" "]
%%   c31; c32; c33; c34; c35; c36
%%   end
%%   subgraph C4 [" "]
%%   c41; c42; c43; c44; c45; c46
%%   end
%%
%%   c --> c1; c --> c2; c --> c3; c --> c4
%%   c1 --- c11 --- c12 --- c13 --- c14 --- c15 --- c16
%%   c2 --- c21 --- c22 --- c23 --- c24 --- c25 --- c26
%%   c3 --- c31 --- c32 --- c33 --- c34 --- c35 --- c36
%%   c4 --- c41 --- c42 --- c43 --- c44 --- c45 --- c46
%%
%%   subgraph D [" "]
%%   d1; d2; d3; d4
%%   end
%%
%%   subgraph D1 [" "]
%%   d11; d12; d13; d14; d15; d16
%%   end
%%   subgraph D2 [" "]
%%   d21; d22; d23; d24; d25; d26
%%   end
%%   subgraph D3 [" "]
%%   d31; d32; d33; d34; d35; d36
%%   end
%%   subgraph D4 [" "]
%%   d41; d42; d43; d44; d45; d46
%%   end
%%
%%   d --> d1; d --> d2; d --> d3; d --> d4
%%   d1 --- d11 --- d12 --- d13 --- d14 --- d15 --- d16
%%   d2 --- d21 --- d22 --- d23 --- d24 --- d25 --- d26
%%   d3 --- d31 --- d32 --- d33 --- d34 --- d35 --- d36
%%   d4 --- d41 --- d42 --- d43 --- d44 --- d45 --- d46
%%
%% </code></pre>
%%
%% level   buckets
%% 1:      [0]
%% 2:      [0 1 2 3]
%% 3:      [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]
%%
%% With each bucket entry of the form ``{bucket-id, hash}'', eg. ``{0,
%% binary()}''.  The hash for each of the entries at level 3 would come from
%% one of the 16 segments, while the hashes for entries at level 1 and 2 are
%% derived from the lower levels.
%%
%% Specifically, the bucket entries in level 2 would come from level 3:
%%   0: hash([ 0  1  2  3])
%%   1: hash([ 4  5  6  7])
%%   2: hash([ 8  9 10 11])
%%   3: hash([12 13 14 15])
%%
%% And the bucket entries in level 1 would come from level 2:
%%   1: hash([hash([ 0  1  2  3])
%%            hash([ 4  5  6  7])
%%            hash([ 8  9 10 11])
%%            hash([12 13 14 15])])
%%
%% When a (key, hash) pair is added to the tree, the key is hashed to
%% determine which segment it belongs to and inserted/upserted into the
%% segment. Rather than update the hash tree on every insert, a dirty bit is
%% set to note that a given segment has changed. The hashes are then updated
%% in bulk before performing a tree exchange
%%
%% To update the hash tree, the code iterates over each dirty segment,
%% building a list of (key, hash) pairs. A hash is computed over this list,
%% and the leaf node in the hash tree corresponding to the given segment is
%% updated.  After iterating over all dirty segments, and thus updating all
%% leaf nodes, the update then continues to update the tree bottom-up,
%% updating only paths that have changed. As designed, the update requires a
%% single sparse scan over the on-disk segments and a minimal traversal up the
%% hash tree.
%%
%% The heavy-lifting of this module is provided by LevelDB. What is logically
%% viewed as sorted on-disk segments is in reality a range of on-disk
%% (segment, key, hash) values written to LevelDB. Each insert of a (key,
%% hash) pair therefore corresponds to a single LevelDB write (no read
%% necessary). Likewise, the update operation is performed using LevelDB
%% iterators.
%%
%% When used for active anti-entropy in Riak, the hash tree is built once and
%% then updated in real-time as writes occur. A key design goal is to ensure
%% that adding (key, hash) pairs to the tree is non-blocking, even during a
%% tree update or a tree exchange. This is accomplished using LevelDB
%% snapshots. Inserts into the tree always write directly to the active
%% LevelDB instance, however updates and exchanges operate over a snapshot of
%% the tree.
%%
%% In order to improve performance, writes are buffered in memory and sent
%% to LevelDB using a single batch write. Writes are flushed whenever the
%% buffer becomes full, as well as before updating the hashtree.
%%
%% Tree exchange is provided by the ``compare/4'' function.
%% The behavior of this function is determined through a provided function
%% that implements logic to get buckets and segments for a given remote tree,
%% as well as a callback invoked as key differences are determined. This
%% generic interface allows for tree exchange to be implemented in a variety
%% of ways, including directly against to local hash tree instances, over
%% distributed Erlang, or over a custom protocol over a TCP socket. See
%% ``local_compare/2'' and ``do_remote/1'' for examples (-ifdef(TEST) only).

-module(hashtree).
-include_lib("kernel/include/logger.hrl").

-export([new/0,
         new/2,
         new/3,
         insert/3,
         insert/4,
         delete/2,
         update_tree/1,
         update_snapshot/1,
         update_perform/1,
         rehash_tree/1,
         flush_buffer/1,
         close/1,
         destroy/1,
         read_meta/2,
         write_meta/3,
         compare/4,
         top_hash/1,
         get_bucket/3,
         key_hashes/2,
         levels/1,
         segments/1,
         width/1,
         mem_levels/1]).

-ifdef(TEST).
-export([local_compare/2]).
-export([run_local/0,
         run_local/1,
         run_concurrent_build/0,
         run_concurrent_build/1,
         run_concurrent_build/2,
         run_multiple/2,
         run_remote/0,
         run_remote/1]).
-endif. % TEST

-ifdef(EQC).
-export([prop_correct/0]).
-include_lib("eqc/include/eqc.hrl").
-endif.

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-define(NUM_SEGMENTS, (1024*1024)).
-define(WIDTH, 1024).
-define(MEM_LEVELS, 0).

-type tree_id_bin() :: <<_:176>>.
-type segment_bin() :: <<_:256, _:_*8>>.
-type bucket_bin()  :: <<_:320>>.
-type meta_bin()    :: <<_:8, _:_*8>>.

-type proplist() :: proplists:proplist().
-type orddict() :: orddict(integer(), binary()).
-type orddict(K, V) :: orddict:orddict(K, V).
-type index() :: non_neg_integer().

-type keydiff() :: {missing | remote_missing | different, binary()}.

-type remote_fun() :: fun((get_bucket | key_hashes | init | final,
                           {integer(), integer()} | integer() | term()) -> any()
                        ).

-type acc_fun(Acc) :: fun(([keydiff()], Acc) -> Acc).

-type select_fun(T) :: fun((orddict(binary(), binary())) -> T).

-type segment_store() :: {eleveldb:db_ref(), string()}.

-record(state, {
    id                  ::  tree_id_bin(),
    index               ::  index(),
    levels              ::  pos_integer(),
    segments            ::  pos_integer(),
    width               ::  pos_integer(),
    mem_levels          ::  integer(),
    tree                ::  dict:dict(),
    ref                 ::  eleveldb:db_ref(),
    path                ::  string(),
    itr                 ::  term(),
    write_buffer        ::  [{put, binary(), binary()} | {delete, binary()}],
    write_buffer_count  ::  integer(),
    dirty_segments      ::  array:array()
}).

-record(itr_state, {
    itr                 ::   term(),
    id                  ::   tree_id_bin(),
    current_segment     ::   '*' | integer(),
    remaining_segments  ::   ['*' | integer()],
    acc_fun             ::   fun(([{binary(),binary()}]) -> any()),
    segment_acc         ::   [{binary(), binary()}],
    final_acc           ::   [{integer(), any()}],
    prefetch=false      ::   boolean()
}).

-opaque hashtree() :: #state{}.
-export_type([hashtree/0,
              tree_id_bin/0,
              keydiff/0,
              remote_fun/0,
              acc_fun/1]).


%% =============================================================================
%% API
%% =============================================================================



-spec new() -> hashtree() | no_return().
new() ->
    new({0,0}).

-spec new({index(), tree_id_bin() | non_neg_integer()}) ->
    hashtree() | no_return().

new(TreeId) ->
    SegmentStore = new_segment_store([]),
    new(TreeId, SegmentStore, []).

-spec new({index(), tree_id_bin() | non_neg_integer()}, proplist()) ->
    hashtree()  | no_return();
    ({index(), tree_id_bin() | non_neg_integer()}, hashtree()) ->
        hashtree() | no_return().
new(TreeId, Options) when is_list(Options) ->
    SegmentStore = new_segment_store(Options),
    new(TreeId, SegmentStore, Options);
new(TreeId, #state{ref = Ref, path = DataDir}) ->
    SegmentStore = {Ref, DataDir},
    new(TreeId, SegmentStore, []).

-spec new({index(), tree_id_bin() | non_neg_integer()},
          segment_store() | hashtree(),
          proplist()) -> hashtree() | no_return().

new(TreeId, #state{ref = Ref, path = DataDir}, Options) ->
    SegmentStore = {Ref, DataDir},
    new(TreeId, SegmentStore, Options);

new({Index,TreeId}, {Ref, DataDir}, Options) ->
    NumSegments = proplists:get_value(segments, Options, ?NUM_SEGMENTS),
    Width = proplists:get_value(width, Options, ?WIDTH),
    MemLevels = proplists:get_value(mem_levels, Options, ?MEM_LEVELS),

    is_integer(NumSegments)
        orelse error({invalid_option, {segments, NumSegments}}),

    is_integer(Width)
        orelse error({invalid_option, {width, Width}}),

    is_integer(MemLevels)
        orelse error({invalid_option, {mem_levels, MemLevels}}),

    NumLevels = erlang:trunc(math:log(NumSegments) / math:log(Width)) + 1,


    #state{
        ref= Ref,
        path= DataDir,
        id=encode_id(TreeId),
        index=Index,
        levels=NumLevels,
        segments=NumSegments,
        width=Width,
        mem_levels=MemLevels,
        %% dirty_segments=gb_sets:new(),
        dirty_segments=bitarray_new(NumSegments),
        write_buffer=[],
        write_buffer_count=0,
        tree=dict:new()
}.

-spec close(hashtree()) -> hashtree().

close(State) ->
    ok = close_iterator(State#state.itr),
    catch eleveldb:close(State#state.ref),
    State#state{itr=undefined}.


close_iterator(undefined) ->
    ok;

close_iterator(Itr) ->
    catch eleveldb:iterator_close(Itr),
    ok.


-spec destroy(string() | hashtree()) -> ok | hashtree().
destroy(Path) when is_list(Path) ->
    ok = eleveldb:destroy(Path, []);
destroy(#state{path = Path} = State) when is_list(Path)->
    %% Assumption: close was already called on all hashtrees that
    %%             use this LevelDB instance,
    ok = eleveldb:destroy(Path, []),
    State.

-spec insert(binary(), binary(), hashtree()) -> hashtree().
insert(Key, ObjHash, State) ->
    insert(Key, ObjHash, State, []).

-spec insert(binary(), binary(), hashtree(), proplist()) -> hashtree().
insert(Key, ObjHash, State, Opts) ->
    Hash = erlang:phash2(Key),
    Segment = Hash rem State#state.segments,
    HKey = encode(State#state.id, Segment, Key),
    case should_insert(HKey, Opts, State) of
        true ->
            State2 = enqueue_action({put, HKey, ObjHash}, State),
            %% Dirty = gb_sets:add_element(Segment, State2#state.dirty_segments),
            Dirty = bitarray_set(Segment, State2#state.dirty_segments),
            State2#state{dirty_segments=Dirty};
        false ->
            State
    end.

enqueue_action(Action, State) ->
    WBuffer = [Action|State#state.write_buffer],
    WCount = State#state.write_buffer_count + 1,
    State2 = State#state{write_buffer=WBuffer,
                         write_buffer_count=WCount},
    State3 = maybe_flush_buffer(State2),
    State3.

maybe_flush_buffer(State=#state{write_buffer_count=WCount}) ->
    Threshold = 200,
    case WCount > Threshold of
        true ->
            flush_buffer(State);
        false ->
            State
    end.

flush_buffer(State=#state{write_buffer=WBuffer}) ->
    %% Write buffer is built backwards, reverse to build update list
    Updates = lists:reverse(WBuffer),
    ok = eleveldb:write(State#state.ref, Updates, []),
    State#state{write_buffer=[],
                write_buffer_count=0}.

-spec delete(binary(), hashtree()) -> hashtree().
delete(Key, State) ->
    Hash = erlang:phash2(Key),
    Segment = Hash rem State#state.segments,
    HKey = encode(State#state.id, Segment, Key),
    State2 = enqueue_action({delete, HKey}, State),
    %% Dirty = gb_sets:add_element(Segment, State2#state.dirty_segments),
    Dirty = bitarray_set(Segment, State2#state.dirty_segments),
    State2#state{dirty_segments=Dirty}.

-spec should_insert(segment_bin(), proplist(), hashtree()) -> boolean().
should_insert(HKey, Opts, State) ->
    IfMissing = proplists:get_value(if_missing, Opts, false),
    case IfMissing of
        true ->
            %% Only insert if object does not already exist
            %% TODO: Use bloom filter so we don't always call get here
            case eleveldb:get(State#state.ref, HKey, []) of
                not_found ->
                    true;
                _ ->
                    false
            end;
        _ ->
            true
    end.

-spec update_snapshot(hashtree()) -> {hashtree(), hashtree()}.
update_snapshot(State=#state{segments=NumSegments}) ->
    State2 = flush_buffer(State),
    SnapState = snapshot(State2),
    State3 = SnapState#state{dirty_segments=bitarray_new(NumSegments)},
    {SnapState, State3}.

-spec update_tree(hashtree()) -> hashtree().
update_tree(State) ->
    State2 = flush_buffer(State),
    State3 = snapshot(State2),
    update_perform(State3).

-spec update_perform(hashtree()) -> hashtree().
update_perform(State2=#state{dirty_segments=Dirty, segments=NumSegments}) ->
    %% Segments = gb_sets:to_list(Dirty),
    Segments = bitarray_to_list(Dirty),
    State3 = update_tree(Segments, State2),
    %% State3#state{dirty_segments=gb_sets:new()}.
    State3#state{dirty_segments=bitarray_new(NumSegments)}.

-spec update_tree([integer()], hashtree()) -> hashtree().
update_tree([], State) ->
    State;
update_tree(Segments, State) ->
    Hashes = orddict:from_list(hashes(State, Segments)),
    Groups = group(Hashes, State#state.width),
    LastLevel = State#state.levels,
    NewState = update_levels(LastLevel, Groups, State),
    NewState.

-spec rehash_tree(hashtree()) -> hashtree().
rehash_tree(State) ->
    State2 = snapshot(State),
    rehash_perform(State2).

-spec rehash_perform(hashtree()) -> hashtree().
rehash_perform(State) ->
    Hashes = orddict:from_list(hashes(State, ['*', '*'])),
    case Hashes of
        [] ->
            State;
        _ ->
            Groups = group(Hashes, State#state.width),
            LastLevel = State#state.levels,
            NewState = update_levels(LastLevel, Groups, State),
            NewState
    end.

-spec top_hash(hashtree()) -> orddict().
top_hash(State) ->
    get_bucket(1, 0, State).

compare(Tree, Remote, AccFun, Acc) ->
    compare(1, 0, Tree, Remote, AccFun, Acc).

-spec levels(hashtree()) -> pos_integer().
levels(#state{levels=L}) ->
    L.

-spec segments(hashtree()) -> pos_integer().
segments(#state{segments=S}) ->
    S.

-spec width(hashtree()) -> pos_integer().
width(#state{width=W}) ->
    W.

-spec mem_levels(hashtree()) -> integer().
mem_levels(#state{mem_levels=M}) ->
    M.

%% Note: meta is currently a one per file thing, even if there are multiple
%%       trees per file. This is intentional. If we want per tree metadata
%%       this will need to be added as a separate thing.
-spec write_meta(binary(), binary(), hashtree()) -> hashtree().
write_meta(Key, Value, State) when is_binary(Key) and is_binary(Value) ->
    HKey = encode_meta(Key),
    ok = eleveldb:put(State#state.ref, HKey, Value, []),
    State.

-spec read_meta(binary(), hashtree()) -> {ok, binary()} | undefined.
read_meta(Key, State) when is_binary(Key) ->
    HKey = encode_meta(Key),
    case eleveldb:get(State#state.ref, HKey, []) of
        {ok, Value} ->
            {ok, Value};
        _ ->
            undefined
    end.

-spec key_hashes(hashtree(), integer()) -> [{'*'|integer(), orddict()}].

key_hashes(State, Segment) ->
    multi_select_segment(State, [Segment], fun(X) -> X end).

-spec get_bucket(integer(), integer(), hashtree()) -> orddict().

get_bucket(Level, Bucket, State) ->
    case Level =< State#state.mem_levels of
        true ->
            get_memory_bucket(Level, Bucket, State);
        false ->
            get_disk_bucket(Level, Bucket, State)
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

-ifndef(old_hash).
md5(Bin) ->
    crypto:hash(md5, Bin).

-ifdef(TEST).
esha(Bin) ->
    crypto:hash(sha, Bin).
-endif.

esha_init() ->
    crypto:hash_init(sha).

esha_update(Ctx, Bin) ->
    crypto:hash_update(Ctx, Bin).

esha_final(Ctx) ->
    crypto:hash_final(Ctx).
-else.
md5(Bin) ->
    crypto:md5(Bin).

-ifdef(TEST).
esha(Bin) ->
    crypto:sha(Bin).
-endif.

esha_init() ->
    crypto:sha_init().

esha_update(Ctx, Bin) ->
    crypto:sha_update(Ctx, Bin).

esha_final(Ctx) ->
    crypto:sha_final(Ctx).
-endif.

-spec set_bucket(integer(), integer(), orddict(), hashtree()) -> hashtree().
set_bucket(Level, Bucket, Val, State) ->
    case Level =< State#state.mem_levels of
        true ->
            set_memory_bucket(Level, Bucket, Val, State);
        false ->
            set_disk_bucket(Level, Bucket, Val, State)
    end.

-spec new_segment_store(proplist()) -> segment_store().

new_segment_store(Opts) when is_list(Opts) ->
    DataDir =
        case proplists:get_value(segment_path, Opts) of
            undefined ->
                Root = "/tmp/anti/level",
                <<P:128/integer>> =
                    md5(term_to_binary({erlang:timestamp(), make_ref()})),
                filename:join(Root, integer_to_list(P));
            SegmentPath when is_list(SegmentPath) ->
                SegmentPath
        end,

    DefaultWriteBufferMin = 30 * 1024 * 1024,
    DefaultWriteBufferMax = 60 * 1024 * 1024,
    Default = [
        {write_buffer_size_min, DefaultWriteBufferMin},
        {write_buffer_size_max, DefaultWriteBufferMax}
    ],
    ConfigVars = plum_db_config:get(aae_leveldb_opts, Default),

    is_list(ConfigVars)
        orelse error({invalid_option, {aae_leveldb_opts, ConfigVars}}),

    %% eqwalizer:ignore ConfigVars
    Config = orddict:from_list(ConfigVars),

    %% Use a variable write buffer size to prevent against all buffers being
    %% flushed to disk at once when under a heavy uniform load.
    WriteBufferMin = proplists:get_value(write_buffer_size_min, Config, DefaultWriteBufferMin),
    WriteBufferMax = proplists:get_value(write_buffer_size_max, Config, DefaultWriteBufferMax),
    Seed = partisan_config:seed(),
    {Offset, _} = rand:uniform_s(1 + WriteBufferMax - WriteBufferMin, Seed),
    WriteBufferSize = WriteBufferMin + Offset,
    Config2 = orddict:store(write_buffer_size, WriteBufferSize, Config),
    Config3 = orddict:erase(write_buffer_size_min, Config2),
    Config4 = orddict:erase(write_buffer_size_max, Config3),
    Config5 = orddict:store(is_internal_db, true, Config4),
    Config6 = orddict:store(use_bloomfilter, true, Config5),
    Options = orddict:to_list(orddict:store(create_if_missing, true, Config6)),

    ok = filelib:ensure_dir(DataDir),
    %% eqwalizer:ignore Options
    {ok, Ref} = eleveldb:open(DataDir, Options),
    {Ref, DataDir}.

-spec hash(term()) -> binary().
hash(X) ->
    %% erlang:phash2(X).
    sha(term_to_binary(X)).

sha(Bin) ->
    Chunk = plum_db_config:get(aae_sha_chunk, 4096),
    sha(Chunk, Bin).

sha(Chunk, Bin) ->
    Ctx1 = esha_init(),
    Ctx2 = sha(Chunk, Bin, Ctx1),
    SHA = esha_final(Ctx2),
    SHA.

sha(Chunk, Bin, Ctx) ->
    case Bin of
        <<Data:Chunk/binary, Rest/binary>> ->
            Ctx2 = esha_update(Ctx, Data),
            sha(Chunk, Rest, Ctx2);
        Data ->
            Ctx2 = esha_update(Ctx, Data),
            Ctx2
    end.

-spec update_levels(integer(),
                    [{integer(), [{integer(), binary()}]}],
                    hashtree()) -> hashtree().
update_levels(0, _, State) ->
    State;
update_levels(Level, Groups, State) ->
    {NewState, NewBuckets} =
        lists:foldl(fun({Bucket, NewHashes}, {StateAcc, BucketsAcc}) ->
                            Hashes1 = get_bucket(Level, Bucket, StateAcc),
                            Hashes2 = orddict:from_list(NewHashes),
                            Hashes3 = orddict:merge(fun(_, _, New) -> New end,
                                                    Hashes1,
                                                    Hashes2),
                            StateAcc2 = set_bucket(Level, Bucket, Hashes3, StateAcc),
                            NewBucket = {Bucket, hash(Hashes3)},
                            {StateAcc2, [NewBucket | BucketsAcc]}
                    end, {State, []}, Groups),
    Groups2 = group(NewBuckets, State#state.width),
    update_levels(Level - 1, Groups2, NewState).

%% Takes a list of bucket-hash entries from level X and groups them together
%% into groups representing entries at parent level X-1.
%%
%% For example, given bucket-hash entries at level X:
%%   [{1,H1}, {2,H2}, {3,H3}, {4,H4}, {5,H5}, {6,H6}, {7,H7}, {8,H8}]
%%
%% The grouping at level X-1 with a width of 4 would be:
%%   [{1,[{1,H1}, {2,H2}, {3,H3}, {4,H4}]},
%%    {2,[{5,H5}, {6,H6}, {7,H7}, {8,H8}]}]
%%
-spec group([{integer(), orddict()}], pos_integer()) ->
    [{integer(), [{integer(), orddict()}]}].

group(L, Width) ->
    {FirstId, _} = hd(L),
    FirstBucket = FirstId div Width,
    {LastBucket, LastGroup, Groups} =
        lists:foldl(fun(X={Id, _}, {LastBucket, Acc, Groups}) ->
                            Bucket = Id div Width,
                            case Bucket of
                                LastBucket ->
                                    {LastBucket, [X|Acc], Groups};
                                _ ->
                                    {Bucket, [X], [{LastBucket, Acc} | Groups]}
                            end
                    end, {FirstBucket, [], []}, L),
    [{LastBucket, LastGroup} | Groups].

-spec get_memory_bucket(integer(), integer(), hashtree()) -> orddict().

get_memory_bucket(Level, Bucket, #state{tree=Tree}) ->
    case dict:find({Level, Bucket}, Tree) of
        error ->
            orddict:new();
        {ok, Val} when is_list(Val) ->
            %% eqwalizer:ignore Val
            Val
    end.

-spec set_memory_bucket(integer(), integer(), orddict(), hashtree()) ->
    hashtree().
set_memory_bucket(Level, Bucket, Val, State) ->
    Tree = dict:store({Level, Bucket}, Val, State#state.tree),
    State#state{tree=Tree}.

-spec get_disk_bucket(integer(), integer(), hashtree()) -> orddict().
get_disk_bucket(Level, Bucket, #state{id=Id, ref=Ref}) ->
    HKey = encode_bucket(Id, Level, Bucket),
    case eleveldb:get(Ref, HKey, []) of
        {ok, Bin} ->
            binary_to_term(Bin);
        _ ->
            orddict:new()
    end.

-spec set_disk_bucket(integer(), integer(), orddict(), hashtree()) -> hashtree().
set_disk_bucket(Level, Bucket, Val, State=#state{id=Id, ref=Ref}) ->
    HKey = encode_bucket(Id, Level, Bucket),
    Bin = term_to_binary(Val),
    ok = eleveldb:put(Ref, HKey, Bin, []),
    State.

-spec encode_id(binary() | non_neg_integer()) -> tree_id_bin().
encode_id(TreeId) when is_integer(TreeId) ->
    if (TreeId >= 0) andalso
       (TreeId < ((1 bsl 160)-1)) ->
            <<TreeId:176/integer>>;
       true ->
            erlang:error(badarg)
    end;
encode_id(TreeId) when is_binary(TreeId) and (byte_size(TreeId) == 22) ->
    TreeId;
encode_id(_) ->
    erlang:error(badarg).

-spec encode(tree_id_bin(), integer(), binary()) -> segment_bin().
encode(TreeId, Segment, Key) ->
    <<$t,TreeId:22/binary,$s,Segment:64/integer,Key/binary>>.

-spec safe_decode(binary()) -> {tree_id_bin() | bad, integer(), binary()}.
safe_decode(Bin) ->
    case Bin of
        <<$t,TreeId:22/binary,$s,Segment:64/integer,Key/binary>> ->
            {TreeId, Segment, Key};
        _ ->
            {bad, -1, <<>>}
    end.

-spec decode(segment_bin()) -> {tree_id_bin(), non_neg_integer(), binary()}.
decode(Bin) ->
    <<$t,TreeId:22/binary,$s,Segment:64/integer,Key/binary>> = Bin,
    {TreeId, Segment, Key}.

-spec encode_bucket(tree_id_bin(), integer(), integer()) -> bucket_bin().
encode_bucket(TreeId, Level, Bucket) ->
    <<$b,TreeId:22/binary,$b,Level:64/integer,Bucket:64/integer>>.

-spec encode_meta(binary()) -> meta_bin().
encode_meta(Key) ->
    <<$m,Key/binary>>.

-spec hashes(hashtree(), list('*'|integer())) ->
    orddict('*'|integer(), binary()).
hashes(State, Segments) ->
    multi_select_segment(State, Segments, fun hash/1).

-spec snapshot(hashtree()) -> hashtree().
snapshot(State) ->
    %% Abuse eleveldb iterators as snapshots
    ok = close_iterator(State#state.itr),
    {ok, Itr} = eleveldb:iterator(State#state.ref, []),
    State#state{itr=Itr}.

-spec multi_select_segment(hashtree(), list('*'|integer()), select_fun(T))
                          -> [{'*'|integer(), T}].

multi_select_segment(#state{id=Id, itr=Itr}, Segments, F) ->
    [First | Rest] = Segments,
    IS1 = #itr_state{itr=Itr,
                     id=Id,
                     current_segment=First,
                     remaining_segments=Rest,
                     acc_fun=F,
                     segment_acc=[],
                     final_acc=[]},
    Seek = case First of
               '*' ->
                   encode(Id, 0, <<>>);
               _ ->
                   encode(Id, First, <<>>)
           end,
    IS2 = iterate(iterator_move(Itr, Seek), IS1),
    #itr_state{current_segment=LastSegment,
               segment_acc=LastAcc,
               final_acc=FA} = IS2,
    Result = [{LastSegment, F(LastAcc)} | FA],

    case Result of
        [{'*', _}] ->
            %% Handle wildcard select when all segments are empty
            [];
        _ ->
            Result
    end.

iterator_move(undefined, _Seek) ->
    {error, invalid_iterator};

iterator_move(Itr, Seek) ->
    try
        eleveldb:iterator_move(Itr, Seek)
    catch
        _:badarg ->
            {error, invalid_iterator}
    end.

-spec iterate({'error','invalid_iterator'} | {'ok',binary(),binary()},
              #itr_state{}) -> #itr_state{}.
iterate({error, invalid_iterator}, IS=#itr_state{}) ->
    IS;
iterate({ok, K, V}, IS=#itr_state{itr=Itr,
                                  id=Id,
                                  current_segment=CurSeg,
                                  remaining_segments=Segments,
                                  acc_fun=F,
                                  segment_acc=Acc,
                                  final_acc=FinalAcc}) ->
    {SegId, Seg, _} = safe_decode(K),
    Segment = case CurSeg of
                  '*' ->
                      Seg;
                  _ ->
                      CurSeg
              end,
    case {SegId, Seg, Segments, IS#itr_state.prefetch} of
        {bad, -1, _, _} ->
            %% Non-segment encountered, end traversal
            IS;
        {Id, Segment, _, _} ->
            %% Still reading existing segment
            IS2 = IS#itr_state{current_segment=Segment,
                               segment_acc=[{K,V} | Acc],
                               prefetch=true},
            iterate(iterator_move(Itr, prefetch), IS2);
        {Id, _, [Seg|Remaining], _} ->
            %% Pointing at next segment we are interested in
            IS2 = IS#itr_state{current_segment=Seg,
                               remaining_segments=Remaining,
                               segment_acc=[{K,V}],
                               final_acc=[{Segment, F(Acc)} | FinalAcc],
                               prefetch=true},
            iterate(iterator_move(Itr, prefetch), IS2);
        {Id, _, ['*'], _} ->
            %% Pointing at next segment we are interested in
            IS2 = IS#itr_state{current_segment=Seg,
                               remaining_segments=['*'],
                               segment_acc=[{K,V}],
                               final_acc=[{Segment, F(Acc)} | FinalAcc],
                               prefetch=true},
            iterate(iterator_move(Itr, prefetch), IS2);
        {Id, NextSeg, [NextSeg|Remaining], _} ->
            %% A previous prefetch_stop left us at the start of the
            %% next interesting segment.
            IS2 = IS#itr_state{current_segment=NextSeg,
                               remaining_segments=Remaining,
                               segment_acc=[{K,V}],
                               prefetch=true},
            iterate(iterator_move(Itr, prefetch), IS2);
        {Id, _, [_NextSeg | _Remaining], true} ->
            %% Pointing at uninteresting segment, but need to halt the
            %% prefetch to ensure the interator can be reused
            IS2 = IS#itr_state{segment_acc=[],
                               final_acc=[{Segment, F(Acc)} | FinalAcc],
                               prefetch=false},
            iterate(iterator_move(Itr, prefetch_stop), IS2);
        {Id, _, [NextSeg | Remaining], false} ->
            %% Pointing at uninteresting segment, seek to next interesting one
            Seek = encode(Id, NextSeg, <<>>),
            IS2 = IS#itr_state{current_segment=NextSeg,
                               remaining_segments=Remaining,
                               segment_acc=[],
                               final_acc=[{Segment, F(Acc)} | FinalAcc]},
            iterate(iterator_move(Itr, Seek), IS2);
        {_, _, _, true} ->
            %% Done with traversal, but need to stop the prefetch to
            %% ensure the iterator can be reused. The next operation
            %% with this iterator is a seek so no need to be concerned
            %% with the data returned here.
            _ = iterator_move(Itr, prefetch_stop),
            IS#itr_state{prefetch=false};
        {_, _, _, false} ->
            %% Done with traversal
            IS
    end.

-spec compare(integer(), integer(), hashtree(), remote_fun(), acc_fun(X), X) -> X.
compare(Level, Bucket, Tree, CallRemote, AccFun, KeyAcc)
when Level == Tree#state.levels + 1 ->
    Keys = compare_segments(Bucket, Tree, CallRemote),
    AccFun(Keys, KeyAcc);

compare(Level, Bucket, Tree, CallRemote, AccFun, KeyAcc) ->
    HL1 = get_bucket(Level, Bucket, Tree),
    %% This functions calls a remote node to the bucket
    HL2 = CallRemote(get_bucket, {Level, Bucket}),
    Union = lists:ukeysort(1, HL1 ++ HL2),
    Inter = ordsets:intersection(ordsets:from_list(HL1),
                                 ordsets:from_list(HL2)),
    Diff = ordsets:subtract(Union, Inter),
    KeyAcc3 =
        lists:foldl(fun({Bucket2, _}, KeyAcc2) ->
                            compare(Level+1, Bucket2, Tree, CallRemote, AccFun, KeyAcc2)
                    end, KeyAcc, Diff),
    KeyAcc3.

-spec compare_segments(integer(), hashtree(), remote_fun()) -> [keydiff()].
compare_segments(Segment, Tree=#state{id=Id}, CallRemote) ->
    [{_, KeyHashes1}] = key_hashes(Tree, Segment),
    KeyHashes2 = CallRemote(key_hashes, Segment),
    HL1 = orddict:from_list(KeyHashes1),
    HL2 = orddict:from_list(KeyHashes2),
    Delta = orddict_delta(HL1, HL2),
    Keys = [begin
                {Id, Segment, Key} = decode(KBin),
                Type = key_diff_type(Diff),
                {Type, Key}
            end || {KBin, Diff} <- Delta],
    Keys.

key_diff_type({'$none', _}) ->
    missing;
key_diff_type({_, '$none'}) ->
    remote_missing;
key_diff_type(_) ->
    different.

orddict_delta(D1, D2) ->
    orddict_delta(D1, D2, []).

orddict_delta([{K1,V1}|D1], [{K2,_}=E2|D2], Acc) when K1 < K2 ->
    Acc2 = [{K1,{V1,'$none'}} | Acc],
    orddict_delta(D1, [E2|D2], Acc2);
orddict_delta([{K1,_}=E1|D1], [{K2,V2}|D2], Acc) when K1 > K2 ->
    Acc2 = [{K2,{'$none',V2}} | Acc],
    orddict_delta([E1|D1], D2, Acc2);
orddict_delta([{K1,V1}|D1], [{_K2,V2}|D2], Acc) -> %K1 == K2
    case V1 of
        V2 ->
            orddict_delta(D1, D2, Acc);
        _ ->
            Acc2 = [{K1,{V1,V2}} | Acc],
            orddict_delta(D1, D2, Acc2)
    end;
orddict_delta([], D2, Acc) ->
    L = [{K2,{'$none',V2}} || {K2,V2} <- D2],
    L ++ Acc;
orddict_delta(D1, [], Acc) ->
    L = [{K1,{V1,'$none'}} || {K1,V1} <- D1],
    L ++ Acc.

%%%===================================================================
%%% bitarray
%%%===================================================================
-define(W, 27).

-spec bitarray_new(integer()) -> array:array().
bitarray_new(N) -> array:new((N-1) div ?W + 1, {default, 0}).

-spec bitarray_set(integer(), array:array()) -> array:array().
bitarray_set(I, A) ->
    AI = I div ?W,
    V = array:get(AI, A),
    V1 = V bor (1 bsl (I rem ?W)),
    array:set(AI, V1, A).

-spec bitarray_to_list(array:array()) -> [integer()].
bitarray_to_list(A) ->
    lists:reverse(
      array:sparse_foldl(fun(I, V, Acc) ->
                                 expand(V, I * ?W, Acc)
                         end, [], A)).

%% Convert bit vector into list of integers, with optional offset.
%% expand(2#01, 0, []) -> [0]
%% expand(2#10, 0, []) -> [1]
%% expand(2#1101, 0,   []) -> [3,2,0]
%% expand(2#1101, 1,   []) -> [4,3,1]
%% expand(2#1101, 10,  []) -> [13,12,10]
%% expand(2#1101, 100, []) -> [103,102,100]
expand(0, _, Acc) ->
    Acc;
expand(V, N, Acc) ->
    Acc2 =
        case (V band 1) of
            1 ->
                [N|Acc];
            0 ->
                Acc
        end,
    expand(V bsr 1, N+1, Acc2).

%%%===================================================================
%%% Experiments
%%%===================================================================

-ifdef(TEST).

run_local() ->
    run_local(10000).
run_local(N) ->
    timer:tc(fun do_local/1, [N]).

run_concurrent_build() ->
    run_concurrent_build(10000).
run_concurrent_build(N) ->
    run_concurrent_build(N, N).
run_concurrent_build(N1, N2) ->
    timer:tc(fun do_concurrent_build/2, [N1, N2]).

run_multiple(Count, N) ->
    Tasks = [fun() ->
                     do_concurrent_build(N, N)
             end || _ <- lists:seq(1, Count)],
    timer:tc(fun peval/1, [Tasks]).

run_remote() ->
    run_remote(100000).
run_remote(N) ->
    timer:tc(fun do_remote/1, [N]).

do_local(N) ->
    A0 = insert_many(N, new()),
    A1 = insert(<<"10">>, <<"42">>, A0),
    A2 = insert(<<"10">>, <<"42">>, A1),
    A3 = insert(<<"13">>, <<"52">>, A2),

    B0 = insert_many(N, new()),
    B1 = insert(<<"14">>, <<"52">>, B0),
    B2 = insert(<<"10">>, <<"32">>, B1),
    B3 = insert(<<"10">>, <<"422">>, B2),

    A4 = update_tree(A3),
    B4 = update_tree(B3),
    KeyDiff = local_compare(A4, B4),
    ?LOG_INFO(#{key_diff => KeyDiff}),
    close(A4),
    close(B4),
    destroy(A4),
    destroy(B4),
    ok.

do_concurrent_build(N1, N2) ->
    F1 = fun() ->
                 A0 = insert_many(N1, new()),
                 A1 = insert(<<"10">>, <<"42">>, A0),
                 A2 = insert(<<"10">>, <<"42">>, A1),
                 A3 = insert(<<"13">>, <<"52">>, A2),
                 A4 = update_tree(A3),
                 A4
         end,

    F2 = fun() ->
                 B0 = insert_many(N2, new()),
                 B1 = insert(<<"14">>, <<"52">>, B0),
                 B2 = insert(<<"10">>, <<"32">>, B1),
                 B3 = insert(<<"10">>, <<"422">>, B2),
                 B4 = update_tree(B3),
                 B4
         end,

    [A4, B4] = peval([F1, F2]),
    KeyDiff = local_compare(A4, B4),
    ?LOG_INFO(#{key_diff => KeyDiff}),

    close(A4),
    close(B4),
    destroy(A4),
    destroy(B4),
    ok.

do_remote(N) ->
    %% Spawn new process for remote tree
    Other =
        spawn(fun() ->
                      A0 = insert_many(N, new()),
                      A1 = insert(<<"10">>, <<"42">>, A0),
                      A2 = insert(<<"10">>, <<"42">>, A1),
                      A3 = insert(<<"13">>, <<"52">>, A2),
                      A4 = update_tree(A3),
                      message_loop(A4, 0, 0)
              end),

    %% Build local tree
    B0 = insert_many(N, new()),
    B1 = insert(<<"14">>, <<"52">>, B0),
    B2 = insert(<<"10">>, <<"32">>, B1),
    B3 = insert(<<"10">>, <<"422">>, B2),
    B4 = update_tree(B3),

    %% Compare with remote tree through message passing
    Remote = fun
        (get_bucket, {L, B}) ->
            ?LOG_WARNING(#{
                other => Other,
                self => self()
            }),
            Other ! {get_bucket, self(), L, B},
            receive {remote, X} -> X end;
        (key_hashes, Segment) ->
            ?LOG_WARNING(#{
                other => Other,
                self => self()
            }),
            Other ! {key_hashes, self(), Segment},
            receive {remote, X} -> X end
    end,

    KeyDiff = compare(B4, Remote),
    ?LOG_INFO(#{key_diff => KeyDiff}),
    %% Signal spawned process to print stats and exit
    Other ! done,
    ok.


send(To, Message) ->
    Ref = partisan:make_ref(),

    %% Figure out remote node.
    {Node, ServerRef} = case To of
        {RemoteProcess, RemoteNode} ->
            {RemoteNode, RemoteProcess};
        _ ->
            {partisan:node(), To}
    end,

    partisan:forward_message(Node, ServerRef, Message, []),

    Ref.



message_loop(Tree, Msgs, Bytes) ->
    receive
        {get_bucket, From, L, B} ->
            Reply = get_bucket(L, B, Tree),
            %% TODO use partisan to reply
            From ! {remote, Reply},
            Size = byte_size(term_to_binary(Reply)),
            message_loop(Tree, Msgs+1, Bytes+Size);
        {key_hashes, From, Segment} ->
            [{_, KeyHashes2}] = key_hashes(Tree, Segment),
            Reply = KeyHashes2,
            %% TODO use partisan to reply
            From ! {remote, Reply},
            Size = byte_size(term_to_binary(Reply)),
            message_loop(Tree, Msgs+1, Bytes+Size);
        done ->
            ?LOG_INFO(#{exchanged_messages => Msgs, exhanged_bytes => Bytes}),
            ok
    end.

insert_many(N, T1) ->
    T2 =
        lists:foldl(fun(X, TX) ->
                            insert(bin(-X), bin(X*100), TX)
                    end, T1, lists:seq(1,N)),
    T2.

bin(X) ->
    list_to_binary(integer_to_list(X)).

peval(L) ->
    Parent = self(),
    lists:foldl(
      fun(F, N) ->
              spawn(fun() ->
                            Parent ! {peval, N, F()}
                    end),
              N+1
      end, 0, L),
    L2 = [receive {peval, N, R} -> {N,R} end || _ <- L],
    {_, L3} = lists:unzip(lists:keysort(1, L2)),
    L3.

%%%===================================================================
%%% EUnit
%%%===================================================================

-spec local_compare(hashtree(), hashtree()) -> [keydiff()].
local_compare(T1, T2) ->
    Remote = fun(get_bucket, {L, B}) ->
                     get_bucket(L, B, T2);
                (key_hashes, Segment) ->
                     [{_, KeyHashes2}] = key_hashes(T2, Segment),
                     KeyHashes2
             end,
    compare(T1, Remote).

-spec compare(hashtree(), remote_fun()) -> [keydiff()].
compare(Tree, Remote) ->
    compare(Tree, Remote, fun(Keys, KeyAcc) ->
                                  Keys ++ KeyAcc
                          end).

-spec compare(hashtree(), remote_fun(), acc_fun(X)) -> X.
compare(Tree, Remote, AccFun) ->
    compare(Tree, Remote, AccFun, []).

%% Verify that `update_tree/1' generates a snapshot of the underlying
%% LevelDB store that is used by `compare', therefore isolating the
%% compare from newer/concurrent insertions into the tree.
snapshot_test() ->
    partisan_config:init(),
    A0 = insert(<<"10">>, <<"42">>, new()),
    B0 = insert(<<"10">>, <<"52">>, new()),
    A1 = update_tree(A0),
    B1 = update_tree(B0),
    B2 = insert(<<"10">>, <<"42">>, B1),
    KeyDiff = local_compare(A1, B1),
    close(A1),
    close(B2),
    destroy(A1),
    destroy(B2),
    ?assertEqual([{different, <<"10">>}], KeyDiff),
    ok.

delta_test() ->
    partisan_config:init(),
    T1 = update_tree(insert(<<"1">>, esha(term_to_binary(make_ref())),
                            new())),
    T2 = update_tree(insert(<<"2">>, esha(term_to_binary(make_ref())),
                            new())),
    Diff = local_compare(T1, T2),
    ?assertEqual([{remote_missing, <<"1">>}, {missing, <<"2">>}], Diff),
    Diff2 = local_compare(T2, T1),
    ?assertEqual([{missing, <<"1">>}, {remote_missing, <<"2">>}], Diff2),
    ok.
-endif.

%%%===================================================================
%%% EQC
%%%===================================================================

-ifdef(EQC).
sha_test_() ->
    {spawn,
     {timeout, 120,
      fun() ->
              ?assert(eqc:quickcheck(eqc:testing_time(4, prop_sha())))
      end
     }}.

prop_sha() ->
    %% NOTE: Generating 1MB (1024 * 1024) size binaries is incredibly slow
    %% with EQC and was using over 2GB of memory
    ?FORALL({Size, NumChunks}, {choose(1, 1024), choose(1, 16)},
                    ?FORALL(Bin, binary(Size),
                            begin
                                %% we need at least one chunk,
                                %% and then we divide the binary size
                                %% into the number of chunks (as a natural
                                %% number)
                                ChunkSize = max(1, (Size div NumChunks)),
                                sha(ChunkSize, Bin) =:= esha(Bin)
                            end)).

eqc_test_() ->
    {spawn,
     {timeout, 120,
      fun() ->
              ?assert(eqc:quickcheck(eqc:testing_time(4, prop_correct())))
      end
     }}.

objects() ->
    ?SIZED(Size, objects(Size+3)).

objects(N) ->
    ?LET(Keys, shuffle(lists:seq(1,N)),
         [{bin(K), binary(8)} || K <- Keys]
        ).

lengths(N) ->
    ?LET(MissingN1,  choose(0,N),
         ?LET(MissingN2,  choose(0,N-MissingN1),
              ?LET(DifferentN, choose(0,N-MissingN1-MissingN2),
                   {MissingN1, MissingN2, DifferentN}))).

mutate(Binary) ->
    L1 = binary_to_list(Binary),
    [X|Xs] = L1,
    X2 = (X+1) rem 256,
    L2 = [X2|Xs],
    list_to_binary(L2).

prop_correct() ->
    ?FORALL(Objects, objects(),
            ?FORALL({MissingN1, MissingN2, DifferentN}, lengths(length(Objects)),
                    begin
                        {RemoteOnly, Objects2} = lists:split(MissingN1, Objects),
                        {LocalOnly,  Objects3} = lists:split(MissingN2, Objects2),
                        {Different,  Same}     = lists:split(DifferentN, Objects3),

                        Different2 = [{Key, mutate(Hash)} || {Key, Hash} <- Different],

                        Insert = fun(Tree, Vals) ->
                                         lists:foldl(fun({Key, Hash}, Acc) ->
                                                             insert(Key, Hash, Acc)
                                                     end, Tree, Vals)
                                 end,

                        A0 = new(),
                        B0 = new(),

                        [begin
                             A1 = new({0,Id}, A0),
                             B1 = new({0,Id}, B0),

                             A2 = Insert(A1, Same),
                             A3 = Insert(A2, LocalOnly),
                             A4 = Insert(A3, Different),

                             B2 = Insert(B1, Same),
                             B3 = Insert(B2, RemoteOnly),
                             B4 = Insert(B3, Different2),

                             A5 = update_tree(A4),
                             B5 = update_tree(B4),

                             Expected =
                                 [{missing, Key}        || {Key, _} <- RemoteOnly] ++
                                 [{remote_missing, Key} || {Key, _} <- LocalOnly] ++
                                 [{different, Key}      || {Key, _} <- Different],

                             KeyDiff = local_compare(A5, B5),

                             ?assertEqual(lists:usort(Expected),
                                          lists:usort(KeyDiff)),

                             %% Reconcile trees
                             A6 = Insert(A5, RemoteOnly),
                             B6 = Insert(B5, LocalOnly),
                             B7 = Insert(B6, Different),
                             A7 = update_tree(A6),
                             B8 = update_tree(B7),
                             ?assertEqual([], local_compare(A7, B8)),
                             true
                         end || Id <- lists:seq(0, 10)],
                        close(A0),
                        close(B0),
                        destroy(A0),
                        destroy(B0),
                        true
                    end)).

-endif.
