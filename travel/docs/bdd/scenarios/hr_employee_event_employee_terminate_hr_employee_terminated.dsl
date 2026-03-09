[SCENARIO: BDD-HR_EMPLOYEE-SEED-hr_employee_event_employee_terminate_hr_employee_terminated] TITLE: HR_EMPLOYEE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_employee_event_employee_terminate_hr_employee_terminated" module="HR_EMPLOYEE"
WHEN when_execute_seed_contract module="HR_EMPLOYEE"
THEN then_seed_contract_should_hold module="HR_EMPLOYEE"
