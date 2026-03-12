[SCENARIO: BDD-SHIPMENT_PICKLIST-SEED-shipment_picklist_action_picklist_read_read] TITLE: SHIPMENT_PICKLIST contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="shipment_picklist_action_picklist_read_read" module="SHIPMENT_PICKLIST"
WHEN when_execute_seed_contract module="SHIPMENT_PICKLIST"
THEN then_seed_contract_should_hold module="SHIPMENT_PICKLIST"
