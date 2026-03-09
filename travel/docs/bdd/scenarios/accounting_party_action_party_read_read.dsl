[SCENARIO: BDD-ACCOUNTING_PARTY-SEED-accounting_party_action_party_read_read] TITLE: ACCOUNTING_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="accounting_party_action_party_read_read" module="ACCOUNTING_PARTY"
WHEN when_execute_seed_contract module="ACCOUNTING_PARTY"
THEN then_seed_contract_should_hold module="ACCOUNTING_PARTY"
