[SCENARIO: BDD-POS_POS_SESSION-SEED-pos_pos_session_workflow_pos_session_session_lifecycle] TITLE: POS_POS_SESSION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_session_workflow_pos_session_session_lifecycle" module="POS_POS_SESSION"
WHEN when_execute_seed_contract module="POS_POS_SESSION"
THEN then_seed_contract_should_hold module="POS_POS_SESSION"
