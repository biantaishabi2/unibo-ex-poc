[SCENARIO: BDD-MARKETING_UTM_STAGE-SEED-marketing_utm_stage_action_utm_stage_read_read] TITLE: MARKETING_UTM_STAGE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="marketing_utm_stage_action_utm_stage_read_read" module="MARKETING_UTM_STAGE"
WHEN when_execute_seed_contract module="MARKETING_UTM_STAGE"
THEN then_seed_contract_should_hold module="MARKETING_UTM_STAGE"
