[SCENARIO: BDD-SALES_QUOTE-SEED-sales_quote_event_quote_accept_sales_quote_accepted] TITLE: SALES_QUOTE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sales_quote_event_quote_accept_sales_quote_accepted" module="SALES_QUOTE"
WHEN when_execute_seed_contract module="SALES_QUOTE"
THEN then_seed_contract_should_hold module="SALES_QUOTE"
