[SCENARIO: BDD-HR_WORK_ENTRY_TYPE-SEED-hr_work_entry_type_action_work_entry_type_create_create] TITLE: HR_WORK_ENTRY_TYPE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_work_entry_type_action_work_entry_type_create_create" module="HR_WORK_ENTRY_TYPE"
WHEN when_execute_seed_contract module="HR_WORK_ENTRY_TYPE"
THEN then_seed_contract_should_hold module="HR_WORK_ENTRY_TYPE"
