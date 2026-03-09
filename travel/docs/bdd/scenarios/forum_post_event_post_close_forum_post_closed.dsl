[SCENARIO: BDD-FORUM_POST-SEED-forum_post_event_post_close_forum_post_closed] TITLE: FORUM_POST contract seed scenario TAGS: seed all
GIVEN given_seed_context id="forum_post_event_post_close_forum_post_closed" module="FORUM_POST"
WHEN when_execute_seed_contract module="FORUM_POST"
THEN then_seed_contract_should_hold module="FORUM_POST"
