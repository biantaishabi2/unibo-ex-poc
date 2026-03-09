[SCENARIO: BDD-HR_EMPLOYEE_SKILL-SEED-hr_employee_skill_action_employee_skill_read_read] TITLE: HR_EMPLOYEE_SKILL contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_employee_skill_action_employee_skill_read_read" module="HR_EMPLOYEE_SKILL"
WHEN when_execute_seed_contract module="HR_EMPLOYEE_SKILL"
THEN then_seed_contract_should_hold module="HR_EMPLOYEE_SKILL"
