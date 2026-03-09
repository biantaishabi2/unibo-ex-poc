[SCENARIO: BDD-DELIVERY_PARTY-SEED-delivery_party_action_party_read_read] TITLE: DELIVERY_PARTY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="delivery_party_action_party_read_read" module="DELIVERY_PARTY"
WHEN when_execute_seed_contract module="DELIVERY_PARTY"
THEN then_seed_contract_should_hold module="DELIVERY_PARTY"
