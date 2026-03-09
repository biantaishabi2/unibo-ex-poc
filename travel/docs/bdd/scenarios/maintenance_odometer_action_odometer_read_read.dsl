[SCENARIO: BDD-MAINTENANCE_ODOMETER-SEED-maintenance_odometer_action_odometer_read_read] TITLE: MAINTENANCE_ODOMETER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="maintenance_odometer_action_odometer_read_read" module="MAINTENANCE_ODOMETER"
WHEN when_execute_seed_contract module="MAINTENANCE_ODOMETER"
THEN then_seed_contract_should_hold module="MAINTENANCE_ODOMETER"
