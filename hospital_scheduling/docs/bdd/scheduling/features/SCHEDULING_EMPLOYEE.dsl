[SCENARIO: BDD-SCHEDULING_EMPLOYEE-SEED-action_employee_read_read] TITLE: SCHEDULING_EMPLOYEE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="action_employee_read_read" module="SCHEDULING_EMPLOYEE"
WHEN when_execute_seed_contract module="SCHEDULING_EMPLOYEE"
THEN then_seed_contract_should_hold module="SCHEDULING_EMPLOYEE"

