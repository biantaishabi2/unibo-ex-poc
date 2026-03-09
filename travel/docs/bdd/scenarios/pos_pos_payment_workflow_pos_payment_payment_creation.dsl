[SCENARIO: BDD-POS_POS_PAYMENT-SEED-pos_pos_payment_workflow_pos_payment_payment_creation] TITLE: POS_POS_PAYMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_payment_workflow_pos_payment_payment_creation" module="POS_POS_PAYMENT"
WHEN when_execute_seed_contract module="POS_POS_PAYMENT"
THEN then_seed_contract_should_hold module="POS_POS_PAYMENT"
