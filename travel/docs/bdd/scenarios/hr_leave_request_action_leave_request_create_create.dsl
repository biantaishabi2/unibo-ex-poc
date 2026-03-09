[SCENARIO: BDD-HR_LEAVE_REQUEST-SEED-hr_leave_request_action_leave_request_create_create] TITLE: HR_LEAVE_REQUEST contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_leave_request_action_leave_request_create_create" module="HR_LEAVE_REQUEST"
WHEN when_execute_seed_contract module="HR_LEAVE_REQUEST"
THEN then_seed_contract_should_hold module="HR_LEAVE_REQUEST"
