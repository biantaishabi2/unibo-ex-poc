[SCENARIO: BDD-INVENTORY_STOCK_MOVE-SEED-inventory_stock_move_action_stock_move_read_read] TITLE: INVENTORY_STOCK_MOVE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="inventory_stock_move_action_stock_move_read_read" module="INVENTORY_STOCK_MOVE"
WHEN when_execute_seed_contract module="INVENTORY_STOCK_MOVE"
THEN then_seed_contract_should_hold module="INVENTORY_STOCK_MOVE"
