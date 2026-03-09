[SCENARIO: BDD-HR_WORK_ENTRY-SEED-hr_work_entry_action_work_entry_create_create] TITLE: HR_WORK_ENTRY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_work_entry_action_work_entry_create_create" module="HR_WORK_ENTRY"
WHEN when_execute_seed_contract module="HR_WORK_ENTRY"
THEN then_seed_contract_should_hold module="HR_WORK_ENTRY"
