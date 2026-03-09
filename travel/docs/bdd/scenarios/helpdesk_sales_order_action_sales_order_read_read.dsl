[SCENARIO: BDD-HELPDESK_SALES_ORDER-SEED-helpdesk_sales_order_action_sales_order_read_read] TITLE: HELPDESK_SALES_ORDER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="helpdesk_sales_order_action_sales_order_read_read" module="HELPDESK_SALES_ORDER"
WHEN when_execute_seed_contract module="HELPDESK_SALES_ORDER"
THEN then_seed_contract_should_hold module="HELPDESK_SALES_ORDER"
