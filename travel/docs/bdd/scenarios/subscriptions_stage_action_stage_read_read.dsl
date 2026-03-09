[SCENARIO: BDD-SUBSCRIPTIONS_STAGE-SEED-subscriptions_stage_action_stage_read_read] TITLE: SUBSCRIPTIONS_STAGE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="subscriptions_stage_action_stage_read_read" module="SUBSCRIPTIONS_STAGE"
WHEN when_execute_seed_contract module="SUBSCRIPTIONS_STAGE"
THEN then_seed_contract_should_hold module="SUBSCRIPTIONS_STAGE"
