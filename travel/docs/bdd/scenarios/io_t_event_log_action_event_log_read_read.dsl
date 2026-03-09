[SCENARIO: BDD-IO_T_EVENT_LOG-SEED-io_t_event_log_action_event_log_read_read] TITLE: IO_T_EVENT_LOG contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_event_log_action_event_log_read_read" module="IO_T_EVENT_LOG"
WHEN when_execute_seed_contract module="IO_T_EVENT_LOG"
THEN then_seed_contract_should_hold module="IO_T_EVENT_LOG"
