[SCENARIO: BDD-COMMON_DATA_SOURCE-SEED-common_data_source_action_data_source_read_read] TITLE: COMMON_DATA_SOURCE contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="common_data_source_action_data_source_read_read" module="COMMON_DATA_SOURCE"
WHEN when_execute_seed_contract module="COMMON_DATA_SOURCE"
THEN then_seed_contract_should_hold module="COMMON_DATA_SOURCE"
