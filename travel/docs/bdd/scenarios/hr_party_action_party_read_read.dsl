[SCENARIO: BDD-HR_PARTY-SEED-hr_party_action_party_read_read] TITLE: HR_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_party_action_party_read_read" module="HR_PARTY"
WHEN when_execute_seed_contract module="HR_PARTY"
THEN then_seed_contract_should_hold module="HR_PARTY"
