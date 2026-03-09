[SCENARIO: BDD-FORUM_TAG-SEED-forum_tag_action_tag_read_read] TITLE: FORUM_TAG contract seed scenario TAGS: seed all
GIVEN given_seed_context id="forum_tag_action_tag_read_read" module="FORUM_TAG"
WHEN when_execute_seed_contract module="FORUM_TAG"
THEN then_seed_contract_should_hold module="FORUM_TAG"
