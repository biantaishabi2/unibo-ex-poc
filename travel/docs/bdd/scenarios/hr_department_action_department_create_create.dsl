[SCENARIO: BDD-HR_DEPARTMENT-SEED-hr_department_action_department_create_create] TITLE: HR_DEPARTMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_department_action_department_create_create" module="HR_DEPARTMENT"
WHEN when_execute_seed_contract module="HR_DEPARTMENT"
THEN then_seed_contract_should_hold module="HR_DEPARTMENT"
