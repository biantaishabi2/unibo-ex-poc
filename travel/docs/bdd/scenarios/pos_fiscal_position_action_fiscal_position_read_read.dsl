[SCENARIO: BDD-POS_FISCAL_POSITION-SEED-pos_fiscal_position_action_fiscal_position_read_read] TITLE: POS_FISCAL_POSITION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_fiscal_position_action_fiscal_position_read_read" module="POS_FISCAL_POSITION"
WHEN when_execute_seed_contract module="POS_FISCAL_POSITION"
THEN then_seed_contract_should_hold module="POS_FISCAL_POSITION"
