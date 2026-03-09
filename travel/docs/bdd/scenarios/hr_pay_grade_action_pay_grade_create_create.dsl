[SCENARIO: BDD-HR_PAY_GRADE-SEED-hr_pay_grade_action_pay_grade_create_create] TITLE: HR_PAY_GRADE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_pay_grade_action_pay_grade_create_create" module="HR_PAY_GRADE"
WHEN when_execute_seed_contract module="HR_PAY_GRADE"
THEN then_seed_contract_should_hold module="HR_PAY_GRADE"
