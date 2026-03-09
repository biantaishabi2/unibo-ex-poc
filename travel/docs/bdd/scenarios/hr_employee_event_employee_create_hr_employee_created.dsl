[SCENARIO: BDD-HR_EMPLOYEE-SEED-hr_employee_event_employee_create_hr_employee_created] TITLE: HR_EMPLOYEE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_employee_event_employee_create_hr_employee_created" module="HR_EMPLOYEE"
WHEN when_execute_seed_contract module="HR_EMPLOYEE"
THEN then_seed_contract_should_hold module="HR_EMPLOYEE"
