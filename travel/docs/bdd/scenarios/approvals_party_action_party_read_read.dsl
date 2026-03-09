[SCENARIO: BDD-APPROVALS_PARTY-SEED-approvals_party_action_party_read_read] TITLE: APPROVALS_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="approvals_party_action_party_read_read" module="APPROVALS_PARTY"
WHEN when_execute_seed_contract module="APPROVALS_PARTY"
THEN then_seed_contract_should_hold module="APPROVALS_PARTY"
