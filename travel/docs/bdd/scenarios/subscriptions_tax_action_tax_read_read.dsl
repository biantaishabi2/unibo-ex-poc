[SCENARIO: BDD-SUBSCRIPTIONS_TAX-SEED-subscriptions_tax_action_tax_read_read] TITLE: SUBSCRIPTIONS_TAX contract seed scenario TAGS: seed all
GIVEN given_seed_context id="subscriptions_tax_action_tax_read_read" module="SUBSCRIPTIONS_TAX"
WHEN when_execute_seed_contract module="SUBSCRIPTIONS_TAX"
THEN then_seed_contract_should_hold module="SUBSCRIPTIONS_TAX"
