[SCENARIO: BDD-HR_DEPARTMENT-SEED-hr_department_workflow_department_department_write_flow] TITLE: HR_DEPARTMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_department_workflow_department_department_write_flow" module="HR_DEPARTMENT"
WHEN when_execute_seed_contract module="HR_DEPARTMENT"
THEN then_seed_contract_should_hold module="HR_DEPARTMENT"
