[SCENARIO: BDD-UOM_UOM-SEED-uom_uom_action_uom_create_create] TITLE: UOM_UOM contract seed scenario TAGS: seed all
GIVEN given_seed_context id="uom_uom_action_uom_create_create" module="UOM_UOM"
WHEN when_execute_seed_contract module="UOM_UOM"
THEN then_seed_contract_should_hold module="UOM_UOM"
