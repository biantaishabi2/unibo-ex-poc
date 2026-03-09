[SCENARIO: BDD-FLEET_DRIVER-SEED-fleet_driver_action_driver_create_create] TITLE: FLEET_DRIVER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="fleet_driver_action_driver_create_create" module="FLEET_DRIVER"
WHEN when_execute_seed_contract module="FLEET_DRIVER"
THEN then_seed_contract_should_hold module="FLEET_DRIVER"
