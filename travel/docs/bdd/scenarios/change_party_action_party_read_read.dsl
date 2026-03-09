[SCENARIO: BDD-CHANGE_PARTY-SEED-change_party_action_party_read_read] TITLE: CHANGE_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="change_party_action_party_read_read" module="CHANGE_PARTY"
WHEN when_execute_seed_contract module="CHANGE_PARTY"
THEN then_seed_contract_should_hold module="CHANGE_PARTY"
