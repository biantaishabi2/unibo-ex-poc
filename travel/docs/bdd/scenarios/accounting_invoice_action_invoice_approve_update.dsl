[SCENARIO: BDD-ACCOUNTING_INVOICE-SEED-accounting_invoice_action_invoice_approve_update] TITLE: ACCOUNTING_INVOICE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="accounting_invoice_action_invoice_approve_update" module="ACCOUNTING_INVOICE"
WHEN when_execute_seed_contract module="ACCOUNTING_INVOICE"
THEN then_seed_contract_should_hold module="ACCOUNTING_INVOICE"
