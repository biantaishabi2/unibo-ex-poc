[SCENARIO: BDD-MEMBERSHIP_PARTY-SEED-membership_party_action_party_read_read] TITLE: MEMBERSHIP_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="membership_party_action_party_read_read" module="MEMBERSHIP_PARTY"
WHEN when_execute_seed_contract module="MEMBERSHIP_PARTY"
THEN then_seed_contract_should_hold module="MEMBERSHIP_PARTY"
