[SCENARIO: BDD-INVENTORY_LOT-SEED-inventory_lot_action_lot_update_update] TITLE: INVENTORY_LOT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="inventory_lot_action_lot_update_update" module="INVENTORY_LOT"
WHEN when_execute_seed_contract module="INVENTORY_LOT"
THEN then_seed_contract_should_hold module="INVENTORY_LOT"
