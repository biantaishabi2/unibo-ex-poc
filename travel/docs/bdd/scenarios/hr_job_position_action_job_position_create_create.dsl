[SCENARIO: BDD-HR_JOB_POSITION-SEED-hr_job_position_action_job_position_create_create] TITLE: HR_JOB_POSITION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_job_position_action_job_position_create_create" module="HR_JOB_POSITION"
WHEN when_execute_seed_contract module="HR_JOB_POSITION"
THEN then_seed_contract_should_hold module="HR_JOB_POSITION"
