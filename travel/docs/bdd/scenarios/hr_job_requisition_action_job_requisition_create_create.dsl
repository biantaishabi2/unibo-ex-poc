[SCENARIO: BDD-HR_JOB_REQUISITION-SEED-hr_job_requisition_action_job_requisition_create_create] TITLE: HR_JOB_REQUISITION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_job_requisition_action_job_requisition_create_create" module="HR_JOB_REQUISITION"
WHEN when_execute_seed_contract module="HR_JOB_REQUISITION"
THEN then_seed_contract_should_hold module="HR_JOB_REQUISITION"
