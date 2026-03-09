[SCENARIO: BDD-POS_POS_ORDER-SEED-pos_pos_order_workflow_pos_order_order_flow] TITLE: POS_POS_ORDER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="pos_pos_order_workflow_pos_order_order_flow" module="POS_POS_ORDER"
WHEN when_execute_seed_contract module="POS_POS_ORDER"
THEN then_seed_contract_should_hold module="POS_POS_ORDER"
