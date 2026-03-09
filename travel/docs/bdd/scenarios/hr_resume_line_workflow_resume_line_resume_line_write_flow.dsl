[SCENARIO: BDD-HR_RESUME_LINE-SEED-hr_resume_line_workflow_resume_line_resume_line_write_flow] TITLE: HR_RESUME_LINE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_resume_line_workflow_resume_line_resume_line_write_flow" module="HR_RESUME_LINE"
WHEN when_execute_seed_contract module="HR_RESUME_LINE"
THEN then_seed_contract_should_hold module="HR_RESUME_LINE"
