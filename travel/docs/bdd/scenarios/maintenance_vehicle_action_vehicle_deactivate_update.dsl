[SCENARIO: BDD-MAINTENANCE_VEHICLE-SEED-maintenance_vehicle_action_vehicle_deactivate_update] TITLE: MAINTENANCE_VEHICLE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="maintenance_vehicle_action_vehicle_deactivate_update" module="MAINTENANCE_VEHICLE"
WHEN when_execute_seed_contract module="MAINTENANCE_VEHICLE"
THEN then_seed_contract_should_hold module="MAINTENANCE_VEHICLE"
