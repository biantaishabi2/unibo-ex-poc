[SCENARIO: BDD-ORGANIZATION_PARTY-SEED-organization_party_action_party_read_read] TITLE: ORGANIZATION_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="organization_party_action_party_read_read" module="ORGANIZATION_PARTY"
WHEN when_execute_seed_contract module="ORGANIZATION_PARTY"
THEN then_seed_contract_should_hold module="ORGANIZATION_PARTY"
