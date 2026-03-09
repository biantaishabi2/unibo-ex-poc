[SCENARIO: BDD-INVENTORY_WAREHOUSE-SEED-inventory_warehouse_action_warehouse_update_update] TITLE: INVENTORY_WAREHOUSE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="inventory_warehouse_action_warehouse_update_update" module="INVENTORY_WAREHOUSE"
WHEN when_execute_seed_contract module="INVENTORY_WAREHOUSE"
THEN then_seed_contract_should_hold module="INVENTORY_WAREHOUSE"
