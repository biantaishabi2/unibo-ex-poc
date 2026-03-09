[SCENARIO: BDD-POS_POS_SESSION-SEED-pos_pos_session_action_pos_session_open_update] TITLE: POS_POS_SESSION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_session_action_pos_session_open_update" module="POS_POS_SESSION"
WHEN when_execute_seed_contract module="POS_POS_SESSION"
THEN then_seed_contract_should_hold module="POS_POS_SESSION"
