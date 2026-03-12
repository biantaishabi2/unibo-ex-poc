[SCENARIO: BDD-DELIVERY_SHIPMENT-SEED-delivery_shipment_action_shipment_destroy_destroy] TITLE: DELIVERY_SHIPMENT contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="delivery_shipment_action_shipment_destroy_destroy" module="DELIVERY_SHIPMENT"
WHEN when_execute_seed_contract module="DELIVERY_SHIPMENT"
THEN then_seed_contract_should_hold module="DELIVERY_SHIPMENT"
