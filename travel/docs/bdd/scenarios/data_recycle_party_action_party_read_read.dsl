[SCENARIO: BDD-DATA_RECYCLE_PARTY-SEED-data_recycle_party_action_party_read_read] TITLE: DATA_RECYCLE_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="data_recycle_party_action_party_read_read" module="DATA_RECYCLE_PARTY"
WHEN when_execute_seed_contract module="DATA_RECYCLE_PARTY"
THEN then_seed_contract_should_hold module="DATA_RECYCLE_PARTY"
