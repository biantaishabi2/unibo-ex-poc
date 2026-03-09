[SCENARIO: BDD-HR_LEAVE_TYPE-SEED-hr_leave_type_action_leave_type_read_read] TITLE: HR_LEAVE_TYPE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_leave_type_action_leave_type_read_read" module="HR_LEAVE_TYPE"
WHEN when_execute_seed_contract module="HR_LEAVE_TYPE"
THEN then_seed_contract_should_hold module="HR_LEAVE_TYPE"
