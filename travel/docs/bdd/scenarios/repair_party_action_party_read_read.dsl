[SCENARIO: BDD-REPAIR_PARTY-SEED-repair_party_action_party_read_read] TITLE: REPAIR_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="repair_party_action_party_read_read" module="REPAIR_PARTY"
WHEN when_execute_seed_contract module="REPAIR_PARTY"
THEN then_seed_contract_should_hold module="REPAIR_PARTY"
