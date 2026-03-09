[SCENARIO: BDD-HR_ATTENDANCE-SEED-hr_attendance_action_attendance_read_read] TITLE: HR_ATTENDANCE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_attendance_action_attendance_read_read" module="HR_ATTENDANCE"
WHEN when_execute_seed_contract module="HR_ATTENDANCE"
THEN then_seed_contract_should_hold module="HR_ATTENDANCE"
