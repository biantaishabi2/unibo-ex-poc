[SCENARIO: BDD-APPROVALS_APPROVER-SEED-approvals_approver_action_approver_read_read] TITLE: APPROVALS_APPROVER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="approvals_approver_action_approver_read_read" module="APPROVALS_APPROVER"
WHEN when_execute_seed_contract module="APPROVALS_APPROVER"
THEN then_seed_contract_should_hold module="APPROVALS_APPROVER"
