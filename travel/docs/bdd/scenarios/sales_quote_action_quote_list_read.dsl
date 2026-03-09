[SCENARIO: BDD-SALES_QUOTE-SEED-sales_quote_action_quote_list_read] TITLE: SALES_QUOTE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sales_quote_action_quote_list_read" module="SALES_QUOTE"
WHEN when_execute_seed_contract module="SALES_QUOTE"
THEN then_seed_contract_should_hold module="SALES_QUOTE"
