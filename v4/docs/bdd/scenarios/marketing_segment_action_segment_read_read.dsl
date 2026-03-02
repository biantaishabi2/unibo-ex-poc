[SCENARIO: BDD-MARKETING_SEGMENT-SEED-marketing_segment_action_segment_read_read] TITLE: MARKETING_SEGMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="marketing_segment_action_segment_read_read" module="MARKETING_SEGMENT"
WHEN when_execute_seed_contract module="MARKETING_SEGMENT"
THEN then_seed_contract_should_hold module="MARKETING_SEGMENT"
