[SCENARIO: BDD-SALES_TAX-SEED-sales_tax_action_tax_compute_read] TITLE: SALES_TAX contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="sales_tax_action_tax_compute_read" module="SALES_TAX"
WHEN when_execute_seed_contract module="SALES_TAX"
THEN then_seed_contract_should_hold module="SALES_TAX"
