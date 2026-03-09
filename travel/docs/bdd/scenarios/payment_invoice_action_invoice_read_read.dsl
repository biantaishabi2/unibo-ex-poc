[SCENARIO: BDD-PAYMENT_INVOICE-SEED-payment_invoice_action_invoice_read_read] TITLE: PAYMENT_INVOICE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="payment_invoice_action_invoice_read_read" module="PAYMENT_INVOICE"
WHEN when_execute_seed_contract module="PAYMENT_INVOICE"
THEN then_seed_contract_should_hold module="PAYMENT_INVOICE"
