[SCENARIO: BDD-POS_POS_CONFIG-SEED-pos_pos_config_workflow_pos_config_config_management] TITLE: POS_POS_CONFIG contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_config_workflow_pos_config_config_management" module="POS_POS_CONFIG"
WHEN when_execute_seed_contract module="POS_POS_CONFIG"
THEN then_seed_contract_should_hold module="POS_POS_CONFIG"
