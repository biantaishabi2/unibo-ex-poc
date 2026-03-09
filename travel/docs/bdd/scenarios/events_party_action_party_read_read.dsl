[SCENARIO: BDD-EVENTS_PARTY-SEED-events_party_action_party_read_read] TITLE: EVENTS_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="events_party_action_party_read_read" module="EVENTS_PARTY"
WHEN when_execute_seed_contract module="EVENTS_PARTY"
THEN then_seed_contract_should_hold module="EVENTS_PARTY"
