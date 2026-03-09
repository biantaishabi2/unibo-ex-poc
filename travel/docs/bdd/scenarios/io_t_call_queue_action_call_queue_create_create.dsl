[SCENARIO: BDD-IO_T_CALL_QUEUE-SEED-io_t_call_queue_action_call_queue_create_create] TITLE: IO_T_CALL_QUEUE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_call_queue_action_call_queue_create_create" module="IO_T_CALL_QUEUE"
WHEN when_execute_seed_contract module="IO_T_CALL_QUEUE"
THEN then_seed_contract_should_hold module="IO_T_CALL_QUEUE"
