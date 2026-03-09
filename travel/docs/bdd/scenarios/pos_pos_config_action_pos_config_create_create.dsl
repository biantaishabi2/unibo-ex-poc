[SCENARIO: BDD-POS_POS_CONFIG-SEED-pos_pos_config_action_pos_config_create_create] TITLE: POS_POS_CONFIG contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_config_action_pos_config_create_create" module="POS_POS_CONFIG"
WHEN when_execute_seed_contract module="POS_POS_CONFIG"
THEN then_seed_contract_should_hold module="POS_POS_CONFIG"
