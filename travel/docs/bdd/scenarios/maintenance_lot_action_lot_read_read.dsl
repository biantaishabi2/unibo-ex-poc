[SCENARIO: BDD-MAINTENANCE_LOT-SEED-maintenance_lot_action_lot_read_read] TITLE: MAINTENANCE_LOT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="maintenance_lot_action_lot_read_read" module="MAINTENANCE_LOT"
WHEN when_execute_seed_contract module="MAINTENANCE_LOT"
THEN then_seed_contract_should_hold module="MAINTENANCE_LOT"
