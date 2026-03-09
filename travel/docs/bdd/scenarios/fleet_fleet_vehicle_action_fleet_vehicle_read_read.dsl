[SCENARIO: BDD-FLEET_FLEET_VEHICLE-SEED-fleet_fleet_vehicle_action_fleet_vehicle_read_read] TITLE: FLEET_FLEET_VEHICLE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="fleet_fleet_vehicle_action_fleet_vehicle_read_read" module="FLEET_FLEET_VEHICLE"
WHEN when_execute_seed_contract module="FLEET_FLEET_VEHICLE"
THEN then_seed_contract_should_hold module="FLEET_FLEET_VEHICLE"
