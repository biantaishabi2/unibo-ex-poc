[SCENARIO: BDD-EXPENSES_EMPLOYEE-SEED-expenses_employee_action_employee_read_read] TITLE: EXPENSES_EMPLOYEE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="expenses_employee_action_employee_read_read" module="EXPENSES_EMPLOYEE"
WHEN when_execute_seed_contract module="EXPENSES_EMPLOYEE"
THEN then_seed_contract_should_hold module="EXPENSES_EMPLOYEE"
