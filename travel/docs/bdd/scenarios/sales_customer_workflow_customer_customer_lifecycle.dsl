[SCENARIO: BDD-SALES_CUSTOMER-SEED-sales_customer_workflow_customer_customer_lifecycle] TITLE: SALES_CUSTOMER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sales_customer_workflow_customer_customer_lifecycle" module="SALES_CUSTOMER"
WHEN when_execute_seed_contract module="SALES_CUSTOMER"
THEN then_seed_contract_should_hold module="SALES_CUSTOMER"
