[SCENARIO: BDD-SUBSCRIPTIONS_PARTY-SEED-subscriptions_party_action_party_read_read] TITLE: SUBSCRIPTIONS_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="subscriptions_party_action_party_read_read" module="SUBSCRIPTIONS_PARTY"
WHEN when_execute_seed_contract module="SUBSCRIPTIONS_PARTY"
THEN then_seed_contract_should_hold module="SUBSCRIPTIONS_PARTY"
