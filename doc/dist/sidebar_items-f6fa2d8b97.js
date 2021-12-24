sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"},{"group":"","headers":[],"id":"license","title":"LICENSE"},{"group":"","headers":[{"anchor":"installation","id":"Installation"},{"anchor":"usage","id":"Usage"},{"anchor":"standalone-testing","id":"Standalone testing"}],"id":"readme","title":"PlumDB"}],"modules":[{"group":"","id":"hashtree","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:acc_fun/1","id":"acc_fun/1"},{"anchor":"t:bucket_bin/0","id":"bucket_bin/0"},{"anchor":"t:hashtree/0","id":"hashtree/0"},{"anchor":"t:index/0","id":"index/0"},{"anchor":"t:keydiff/0","id":"keydiff/0"},{"anchor":"t:meta_bin/0","id":"meta_bin/0"},{"anchor":"t:orddict/0","id":"orddict/0"},{"anchor":"t:proplist/0","id":"proplist/0"},{"anchor":"t:remote_fun/0","id":"remote_fun/0"},{"anchor":"t:segment_bin/0","id":"segment_bin/0"},{"anchor":"t:select_fun/1","id":"select_fun/1"},{"anchor":"t:tree_id_bin/0","id":"tree_id_bin/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"close/1","id":"close/1"},{"anchor":"compare/4","id":"compare/4"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"destroy/1","id":"destroy/1"},{"anchor":"flush_buffer/1","id":"flush_buffer/1"},{"anchor":"get_bucket/3","id":"get_bucket/3"},{"anchor":"insert/3","id":"insert/3"},{"anchor":"insert/4","id":"insert/4"},{"anchor":"key_hashes/2","id":"key_hashes/2"},{"anchor":"levels/1","id":"levels/1"},{"anchor":"mem_levels/1","id":"mem_levels/1"},{"anchor":"new/0","id":"new/0"},{"anchor":"new/2","id":"new/2"},{"anchor":"new/3","id":"new/3"},{"anchor":"read_meta/2","id":"read_meta/2"},{"anchor":"rehash_tree/1","id":"rehash_tree/1"},{"anchor":"segments/1","id":"segments/1"},{"anchor":"top_hash/1","id":"top_hash/1"},{"anchor":"update_perform/1","id":"update_perform/1"},{"anchor":"update_snapshot/1","id":"update_snapshot/1"},{"anchor":"update_tree/1","id":"update_tree/1"},{"anchor":"width/1","id":"width/1"},{"anchor":"write_meta/3","id":"write_meta/3"}]}],"sections":[],"title":"hashtree"},{"group":"","id":"hashtree_tree","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:diff/0","id":"diff/0"},{"anchor":"t:handler_fun/1","id":"handler_fun/1"},{"anchor":"t:insert_opt/0","id":"insert_opt/0"},{"anchor":"t:insert_opt_if_missing/0","id":"insert_opt_if_missing/0"},{"anchor":"t:insert_opts/0","id":"insert_opts/0"},{"anchor":"t:key_diffs/0","id":"key_diffs/0"},{"anchor":"t:new_opt/0","id":"new_opt/0"},{"anchor":"t:new_opt_data_dir/0","id":"new_opt_data_dir/0"},{"anchor":"t:new_opt_num_levels/0","id":"new_opt_num_levels/0"},{"anchor":"t:new_opts/0","id":"new_opts/0"},{"anchor":"t:prefix/0","id":"prefix/0"},{"anchor":"t:prefix_diff/0","id":"prefix_diff/0"},{"anchor":"t:prefixes/0","id":"prefixes/0"},{"anchor":"t:remote_fun/0","id":"remote_fun/0"},{"anchor":"t:tree/0","id":"tree/0"},{"anchor":"t:tree_node/0","id":"tree_node/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"compare/4","id":"compare/4"},{"anchor":"delete/3","id":"delete/3"},{"anchor":"destroy/1","id":"destroy/1"},{"anchor":"get_bucket/4","id":"get_bucket/4"},{"anchor":"insert/4","id":"insert/4"},{"anchor":"insert/5","id":"insert/5"},{"anchor":"key_hashes/3","id":"key_hashes/3"},{"anchor":"local_compare/2","id":"local_compare/2"},{"anchor":"new/2","id":"new/2"},{"anchor":"prefix_hash/2","id":"prefix_hash/2"},{"anchor":"top_hash/1","id":"top_hash/1"},{"anchor":"update_perform/1","id":"update_perform/1"},{"anchor":"update_snapshot/1","id":"update_snapshot/1"}]}],"sections":[],"title":"hashtree_tree"},{"group":"","id":"plum_db","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:continuation/0","id":"continuation/0"},{"anchor":"t:continuation_or_eot/0","id":"continuation_or_eot/0"},{"anchor":"t:delete_opts/0","id":"delete_opts/0"},{"anchor":"t:eot/0","id":"eot/0"},{"anchor":"t:erase_opts/0","id":"erase_opts/0"},{"anchor":"t:fold_elements_fun/0","id":"fold_elements_fun/0"},{"anchor":"t:fold_fun/0","id":"fold_fun/0"},{"anchor":"t:fold_opts/0","id":"fold_opts/0"},{"anchor":"t:foreach_fun/0","id":"foreach_fun/0"},{"anchor":"t:get_opt/0","id":"get_opt/0"},{"anchor":"t:get_opt_allow_put/0","id":"get_opt_allow_put/0"},{"anchor":"t:get_opt_default_val/0","id":"get_opt_default_val/0"},{"anchor":"t:get_opt_resolver/0","id":"get_opt_resolver/0"},{"anchor":"t:get_opts/0","id":"get_opts/0"},{"anchor":"t:it_opt/0","id":"it_opt/0"},{"anchor":"t:it_opt_default/0","id":"it_opt_default/0"},{"anchor":"t:it_opt_default_fun/0","id":"it_opt_default_fun/0"},{"anchor":"t:it_opt_first/0","id":"it_opt_first/0"},{"anchor":"t:it_opt_keymatch/0","id":"it_opt_keymatch/0"},{"anchor":"t:it_opt_keys_only/0","id":"it_opt_keys_only/0"},{"anchor":"t:it_opt_partitions/0","id":"it_opt_partitions/0"},{"anchor":"t:it_opt_resolver/0","id":"it_opt_resolver/0"},{"anchor":"t:it_opts/0","id":"it_opts/0"},{"anchor":"t:iterator/0","id":"iterator/0"},{"anchor":"t:iterator_element/0","id":"iterator_element/0"},{"anchor":"t:match_opt_limit/0","id":"match_opt_limit/0"},{"anchor":"t:match_opt_remove_tombstones/0","id":"match_opt_remove_tombstones/0"},{"anchor":"t:match_opts/0","id":"match_opts/0"},{"anchor":"t:partition/0","id":"partition/0"},{"anchor":"t:plum_db_broadcast/0","id":"plum_db_broadcast/0"},{"anchor":"t:plum_db_context/0","id":"plum_db_context/0"},{"anchor":"t:plum_db_key/0","id":"plum_db_key/0"},{"anchor":"t:plum_db_modifier/0","id":"plum_db_modifier/0"},{"anchor":"t:plum_db_object/0","id":"plum_db_object/0"},{"anchor":"t:plum_db_pkey/0","id":"plum_db_pkey/0"},{"anchor":"t:plum_db_pkey_pattern/0","id":"plum_db_pkey_pattern/0"},{"anchor":"t:plum_db_prefix/0","id":"plum_db_prefix/0"},{"anchor":"t:plum_db_prefix_pattern/0","id":"plum_db_prefix_pattern/0"},{"anchor":"t:plum_db_resolver/0","id":"plum_db_resolver/0"},{"anchor":"t:plum_db_tombstone/0","id":"plum_db_tombstone/0"},{"anchor":"t:plum_db_value/0","id":"plum_db_value/0"},{"anchor":"t:plum_db_wildcard/0","id":"plum_db_wildcard/0"},{"anchor":"t:prefix_type/0","id":"prefix_type/0"},{"anchor":"t:prefixes/0","id":"prefixes/0"},{"anchor":"t:put_opts/0","id":"put_opts/0"},{"anchor":"t:remote_iterator/0","id":"remote_iterator/0"},{"anchor":"t:state/0","id":"state/0"},{"anchor":"t:value_or_values/0","id":"value_or_values/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"broadcast_data/1","id":"broadcast_data/1"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"delete/3","id":"delete/3"},{"anchor":"erase/2","id":"erase/2"},{"anchor":"erase/3","id":"erase/3"},{"anchor":"exchange/1","id":"exchange/1"},{"anchor":"exchange/2","id":"exchange/2"},{"anchor":"fold/3","id":"fold/3"},{"anchor":"fold/4","id":"fold/4"},{"anchor":"fold_elements/3","id":"fold_elements/3"},{"anchor":"fold_elements/4","id":"fold_elements/4"},{"anchor":"foreach/2","id":"foreach/2"},{"anchor":"foreach/3","id":"foreach/3"},{"anchor":"get/2","id":"get/2"},{"anchor":"get/3","id":"get/3"},{"anchor":"get_object/1","id":"get_object/1"},{"anchor":"get_object/2","id":"get_object/2"},{"anchor":"get_object/3","id":"get_object/3"},{"anchor":"graft/1","id":"graft/1"},{"anchor":"is_partition/1","id":"is_partition/1"},{"anchor":"is_stale/1","id":"is_stale/1"},{"anchor":"iterate/1","id":"iterate/1"},{"anchor":"iterator/0","id":"iterator/0"},{"anchor":"iterator/1","id":"iterator/1"},{"anchor":"iterator/2","id":"iterator/2"},{"anchor":"iterator_close/1","id":"iterator_close/1"},{"anchor":"iterator_default/1","id":"iterator_default/1"},{"anchor":"iterator_done/1","id":"iterator_done/1"},{"anchor":"iterator_element/1","id":"iterator_element/1"},{"anchor":"iterator_key/1","id":"iterator_key/1"},{"anchor":"iterator_key_value/1","id":"iterator_key_value/1"},{"anchor":"iterator_key_values/1","id":"iterator_key_values/1"},{"anchor":"iterator_prefix/1","id":"iterator_prefix/1"},{"anchor":"match/1","id":"match/1"},{"anchor":"match/2","id":"match/2"},{"anchor":"match/3","id":"match/3"},{"anchor":"merge/2","id":"merge/2"},{"anchor":"merge/3","id":"merge/3"},{"anchor":"partition_count/0","id":"partition_count/0"},{"anchor":"partitions/0","id":"partitions/0"},{"anchor":"prefix_hash/2","id":"prefix_hash/2"},{"anchor":"prefix_type/1","id":"prefix_type/1"},{"anchor":"prefixes/0","id":"prefixes/0"},{"anchor":"put/3","id":"put/3"},{"anchor":"put/4","id":"put/4"},{"anchor":"remote_iterator/1","id":"remote_iterator/1"},{"anchor":"remote_iterator/2","id":"remote_iterator/2"},{"anchor":"start_link/0","id":"start_link/0"},{"anchor":"sync_exchange/1","id":"sync_exchange/1"},{"anchor":"sync_exchange/2","id":"sync_exchange/2"},{"anchor":"take/2","id":"take/2"},{"anchor":"take/3","id":"take/3"},{"anchor":"to_list/1","id":"to_list/1"},{"anchor":"to_list/2","id":"to_list/2"}]}],"sections":[],"title":"plum_db"},{"group":"","id":"plum_db_app","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"prep_stop/1","id":"prep_stop/1"},{"anchor":"start/2","id":"start/2"},{"anchor":"start_phase/3","id":"start_phase/3"},{"anchor":"stop/1","id":"stop/1"}]}],"sections":[],"title":"plum_db_app"},{"group":"","id":"plum_db_config","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"get/1","id":"get/1"},{"anchor":"get/2","id":"get/2"},{"anchor":"init/0","id":"init/0"},{"anchor":"on_set/2","id":"on_set/2"},{"anchor":"set/2","id":"set/2"},{"anchor":"will_set/2","id":"will_set/2"}]}],"sections":[],"title":"plum_db_config"},{"group":"","id":"plum_db_console","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"members/1","id":"members/1"}]}],"sections":[],"title":"plum_db_console"},{"group":"","id":"plum_db_dvvset","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:clock/0","id":"clock/0"},{"anchor":"t:counter/0","id":"counter/0"},{"anchor":"t:entries/0","id":"entries/0"},{"anchor":"t:id/0","id":"id/0"},{"anchor":"t:value/0","id":"value/0"},{"anchor":"t:values/0","id":"values/0"},{"anchor":"t:vector/0","id":"vector/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"equal/2","id":"equal/2"},{"anchor":"ids/1","id":"ids/1"},{"anchor":"join/1","id":"join/1"},{"anchor":"last/2","id":"last/2"},{"anchor":"less/2","id":"less/2"},{"anchor":"lww/2","id":"lww/2"},{"anchor":"map/2","id":"map/2"},{"anchor":"new/1","id":"new/1"},{"anchor":"new/2","id":"new/2"},{"anchor":"reconcile/2","id":"reconcile/2"},{"anchor":"size/1","id":"size/1"},{"anchor":"sync/1","id":"sync/1"},{"anchor":"update/2","id":"update/2"},{"anchor":"update/3","id":"update/3"},{"anchor":"values/1","id":"values/1"}]}],"sections":[],"title":"plum_db_dvvset"},{"group":"","id":"plum_db_events","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"add_callback/1","id":"add_callback/1"},{"anchor":"add_handler/2","id":"add_handler/2"},{"anchor":"add_sup_callback/1","id":"add_sup_callback/1"},{"anchor":"add_sup_handler/2","id":"add_sup_handler/2"},{"anchor":"code_change/3","id":"code_change/3"},{"anchor":"delete_handler/1","id":"delete_handler/1"},{"anchor":"delete_handler/2","id":"delete_handler/2"},{"anchor":"handle_call/2","id":"handle_call/2"},{"anchor":"handle_event/2","id":"handle_event/2"},{"anchor":"handle_info/2","id":"handle_info/2"},{"anchor":"init/1","id":"init/1"},{"anchor":"notify/2","id":"notify/2"},{"anchor":"start_link/0","id":"start_link/0"},{"anchor":"subscribe/1","id":"subscribe/1"},{"anchor":"subscribe/2","id":"subscribe/2"},{"anchor":"terminate/2","id":"terminate/2"},{"anchor":"unsubscribe/1","id":"unsubscribe/1"},{"anchor":"update/1","id":"update/1"}]}],"sections":[],"title":"plum_db_events"},{"group":"","id":"plum_db_exchange_statem","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"acquiring_locks/3","id":"acquiring_locks/3"},{"anchor":"callback_mode/0","id":"callback_mode/0"},{"anchor":"code_change/4","id":"code_change/4"},{"anchor":"exchanging_data/3","id":"exchanging_data/3"},{"anchor":"init/1","id":"init/1"},{"anchor":"start/2","id":"start/2"},{"anchor":"start_link/2","id":"start_link/2"},{"anchor":"terminate/3","id":"terminate/3"},{"anchor":"updating_hashtrees/3","id":"updating_hashtrees/3"}]}],"sections":[],"title":"plum_db_exchange_statem"},{"group":"","id":"plum_db_exchanges_sup","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"init/1","id":"init/1"},{"anchor":"start_exchange/2","id":"start_exchange/2"},{"anchor":"start_link/0","id":"start_link/0"},{"anchor":"stop_exchange/1","id":"stop_exchange/1"}]}],"sections":[],"title":"plum_db_exchanges_sup"},{"group":"","id":"plum_db_object","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:plum_db_context/0","id":"plum_db_context/0"},{"anchor":"t:plum_db_modifier/0","id":"plum_db_modifier/0"},{"anchor":"t:plum_db_object/0","id":"plum_db_object/0"},{"anchor":"t:plum_db_tombstone/0","id":"plum_db_tombstone/0"},{"anchor":"t:plum_db_value/0","id":"plum_db_value/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"context/1","id":"context/1"},{"anchor":"empty_context/0","id":"empty_context/0"},{"anchor":"equal_context/2","id":"equal_context/2"},{"anchor":"hash/1","id":"hash/1"},{"anchor":"is_stale/2","id":"is_stale/2"},{"anchor":"modify/4","id":"modify/4"},{"anchor":"reconcile/2","id":"reconcile/2"},{"anchor":"resolve/2","id":"resolve/2"},{"anchor":"value/1","id":"value/1"},{"anchor":"value_count/1","id":"value_count/1"},{"anchor":"values/1","id":"values/1"}]}],"sections":[],"title":"plum_db_object"},{"group":"","id":"plum_db_partition_hashtree","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:plum_db_key/0","id":"plum_db_key/0"},{"anchor":"t:plum_db_pkey/0","id":"plum_db_pkey/0"},{"anchor":"t:plum_db_prefix/0","id":"plum_db_prefix/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"code_change/3","id":"code_change/3"},{"anchor":"compare/4","id":"compare/4"},{"anchor":"delete/1","id":"delete/1"},{"anchor":"delete/2","id":"delete/2"},{"anchor":"get_bucket/5","id":"get_bucket/5"},{"anchor":"handle_call/3","id":"handle_call/3"},{"anchor":"handle_cast/2","id":"handle_cast/2"},{"anchor":"handle_info/2","id":"handle_info/2"},{"anchor":"init/1","id":"init/1"},{"anchor":"insert/2","id":"insert/2"},{"anchor":"insert/3","id":"insert/3"},{"anchor":"insert/4","id":"insert/4"},{"anchor":"key_hashes/4","id":"key_hashes/4"},{"anchor":"lock/1","id":"lock/1"},{"anchor":"lock/2","id":"lock/2"},{"anchor":"lock/3","id":"lock/3"},{"anchor":"name/1","id":"name/1"},{"anchor":"prefix_hash/2","id":"prefix_hash/2"},{"anchor":"release_lock/1","id":"release_lock/1"},{"anchor":"release_lock/2","id":"release_lock/2"},{"anchor":"release_lock/3","id":"release_lock/3"},{"anchor":"reset/1","id":"reset/1"},{"anchor":"reset/2","id":"reset/2"},{"anchor":"start_link/1","id":"start_link/1"},{"anchor":"terminate/2","id":"terminate/2"},{"anchor":"update/1","id":"update/1"},{"anchor":"update/2","id":"update/2"}]}],"sections":[],"title":"plum_db_partition_hashtree"},{"group":"","id":"plum_db_partition_server","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:db_info/0","id":"db_info/0"},{"anchor":"t:iterator/0","id":"iterator/0"},{"anchor":"t:iterator_action/0","id":"iterator_action/0"},{"anchor":"t:iterator_move_result/0","id":"iterator_move_result/0"},{"anchor":"t:opts/0","id":"opts/0"},{"anchor":"t:plum_db_key/0","id":"plum_db_key/0"},{"anchor":"t:plum_db_pkey/0","id":"plum_db_pkey/0"},{"anchor":"t:plum_db_prefix/0","id":"plum_db_prefix/0"},{"anchor":"t:plum_db_prefix_pattern/0","id":"plum_db_prefix_pattern/0"},{"anchor":"t:plum_db_wildcard/0","id":"plum_db_wildcard/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"byte_size/1","id":"byte_size/1"},{"anchor":"code_change/3","id":"code_change/3"},{"anchor":"erase/3","id":"erase/3"},{"anchor":"get/2","id":"get/2"},{"anchor":"get/3","id":"get/3"},{"anchor":"get/4","id":"get/4"},{"anchor":"handle_call/3","id":"handle_call/3"},{"anchor":"handle_cast/2","id":"handle_cast/2"},{"anchor":"handle_info/2","id":"handle_info/2"},{"anchor":"init/1","id":"init/1"},{"anchor":"is_empty/1","id":"is_empty/1"},{"anchor":"iterator/2","id":"iterator/2"},{"anchor":"iterator/3","id":"iterator/3"},{"anchor":"iterator_close/2","id":"iterator_close/2"},{"anchor":"iterator_move/2","id":"iterator_move/2"},{"anchor":"key_iterator/2","id":"key_iterator/2"},{"anchor":"key_iterator/3","id":"key_iterator/3"},{"anchor":"merge/3","id":"merge/3"},{"anchor":"merge/4","id":"merge/4"},{"anchor":"put/3","id":"put/3"},{"anchor":"put/4","id":"put/4"},{"anchor":"put/5","id":"put/5"},{"anchor":"start_link/2","id":"start_link/2"},{"anchor":"take/2","id":"take/2"},{"anchor":"take/3","id":"take/3"},{"anchor":"take/4","id":"take/4"},{"anchor":"terminate/2","id":"terminate/2"}]}],"sections":[],"title":"plum_db_partition_server"},{"group":"","id":"plum_db_partition_sup","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"init/1","id":"init/1"},{"anchor":"start_link/1","id":"start_link/1"}]}],"sections":[],"title":"plum_db_partition_sup"},{"group":"","id":"plum_db_partitions_sup","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"get_db_info/1","id":"get_db_info/1"},{"anchor":"init/1","id":"init/1"},{"anchor":"set_db_info/2","id":"set_db_info/2"},{"anchor":"start_link/0","id":"start_link/0"}]}],"sections":[],"title":"plum_db_partitions_sup"},{"group":"","id":"plum_db_peer_service","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:partisan_peer/0","id":"partisan_peer/0"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:connections/0","id":"connections/0"},{"anchor":"c:decode/0","id":"decode/0"},{"anchor":"c:join/1","id":"join/1"},{"anchor":"c:join/2","id":"join/2"},{"anchor":"c:join/3","id":"join/3"},{"anchor":"c:leave/0","id":"leave/0"},{"anchor":"c:leave/1","id":"leave/1"},{"anchor":"c:manager/0","id":"manager/0"},{"anchor":"c:members/0","id":"members/0"},{"anchor":"c:mynode/0","id":"mynode/0"},{"anchor":"c:myself/0","id":"myself/0"},{"anchor":"c:stop/0","id":"stop/0"},{"anchor":"c:stop/1","id":"stop/1"},{"anchor":"c:sync_join/1","id":"sync_join/1"},{"anchor":"c:sync_join/2","id":"sync_join/2"},{"anchor":"c:sync_join/3","id":"sync_join/3"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"add_sup_callback/1","id":"add_sup_callback/1"},{"anchor":"cast_message/3","id":"cast_message/3"},{"anchor":"connections/0","id":"connections/0"},{"anchor":"decode/1","id":"decode/1"},{"anchor":"forward_message/3","id":"forward_message/3"},{"anchor":"join/1","id":"join/1"},{"anchor":"join/2","id":"join/2"},{"anchor":"join/3","id":"join/3"},{"anchor":"leave/0","id":"leave/0"},{"anchor":"leave/1","id":"leave/1"},{"anchor":"manager/0","id":"manager/0"},{"anchor":"members/0","id":"members/0"},{"anchor":"mynode/0","id":"mynode/0"},{"anchor":"myself/0","id":"myself/0"},{"anchor":"peer/1","id":"peer/1"},{"anchor":"peer/2","id":"peer/2"},{"anchor":"peer_service/0","id":"peer_service/0"},{"anchor":"stop/0","id":"stop/0"},{"anchor":"stop/1","id":"stop/1"},{"anchor":"sync_join/1","id":"sync_join/1"},{"anchor":"sync_join/2","id":"sync_join/2"},{"anchor":"sync_join/3","id":"sync_join/3"},{"anchor":"update_members/1","id":"update_members/1"}]}],"sections":[],"title":"plum_db_peer_service"},{"group":"","id":"plum_db_pubsub","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:event/0","id":"event/0"},{"anchor":"t:msg/0","id":"msg/0"},{"anchor":"t:scope/0","id":"scope/0"},{"anchor":"t:status/0","id":"status/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"change_cond/3","id":"change_cond/3"},{"anchor":"create_single/2","id":"create_single/2"},{"anchor":"delete_single/2","id":"delete_single/2"},{"anchor":"disable_single/2","id":"disable_single/2"},{"anchor":"enable_single/2","id":"enable_single/2"},{"anchor":"list_singles/2","id":"list_singles/2"},{"anchor":"list_subs/2","id":"list_subs/2"},{"anchor":"notify_single_if_true/4","id":"notify_single_if_true/4"},{"anchor":"publish/3","id":"publish/3"},{"anchor":"publish_cond/3","id":"publish_cond/3"},{"anchor":"subscribe/2","id":"subscribe/2"},{"anchor":"subscribe_cond/3","id":"subscribe_cond/3"},{"anchor":"tell_singles/3","id":"tell_singles/3"},{"anchor":"unsubscribe/2","id":"unsubscribe/2"}]}],"sections":[],"title":"plum_db_pubsub"},{"group":"","id":"plum_db_startup_coordinator","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:state/0","id":"state/0"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"start_link/0","id":"start_link/0"},{"anchor":"stop/0","id":"stop/0"},{"anchor":"wait_for_hashtrees/0","id":"wait_for_hashtrees/0"},{"anchor":"wait_for_hashtrees/1","id":"wait_for_hashtrees/1"},{"anchor":"wait_for_partitions/0","id":"wait_for_partitions/0"},{"anchor":"wait_for_partitions/1","id":"wait_for_partitions/1"}]}],"sections":[],"title":"plum_db_startup_coordinator"},{"group":"","id":"plum_db_sup","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"init/1","id":"init/1"},{"anchor":"start_link/0","id":"start_link/0"}]}],"sections":[],"title":"plum_db_sup"},{"group":"","id":"plum_db_table_owner","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"add/2","id":"add/2"},{"anchor":"add_and_claim/2","id":"add_and_claim/2"},{"anchor":"add_or_claim/2","id":"add_or_claim/2"},{"anchor":"claim/1","id":"claim/1"},{"anchor":"code_change/3","id":"code_change/3"},{"anchor":"delete/1","id":"delete/1"},{"anchor":"exists/1","id":"exists/1"},{"anchor":"give_away/2","id":"give_away/2"},{"anchor":"handle_call/3","id":"handle_call/3"},{"anchor":"handle_cast/2","id":"handle_cast/2"},{"anchor":"handle_info/2","id":"handle_info/2"},{"anchor":"init/1","id":"init/1"},{"anchor":"lookup/1","id":"lookup/1"},{"anchor":"start_link/0","id":"start_link/0"},{"anchor":"terminate/2","id":"terminate/2"}]}],"sections":[],"title":"plum_db_table_owner"}],"tasks":[]}