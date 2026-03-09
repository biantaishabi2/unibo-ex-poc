[SCENARIO: BDD-FORUM_VOTE-SEED-forum_vote_event_vote_create_forum_vote_created] TITLE: FORUM_VOTE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="forum_vote_event_vote_create_forum_vote_created" module="FORUM_VOTE"
WHEN when_execute_seed_contract module="FORUM_VOTE"
THEN then_seed_contract_should_hold module="FORUM_VOTE"
