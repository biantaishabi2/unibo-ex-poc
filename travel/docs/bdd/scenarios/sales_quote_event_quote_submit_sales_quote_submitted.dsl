[SCENARIO: BDD-SALES_QUOTE-SEED-sales_quote_event_quote_submit_sales_quote_submitted] TITLE: SALES_QUOTE contract seed scenario TAGS: seed event_contract
GIVEN given_seed_context id="sales_quote_event_quote_submit_sales_quote_submitted" module="SALES_QUOTE"
WHEN when_execute_seed_contract module="SALES_QUOTE"
THEN then_seed_contract_should_hold module="SALES_QUOTE"
