[SCENARIO: BDD-HR_PAY_SLIP-SEED-hr_pay_slip_workflow_pay_slip_payslip_refund_flow] TITLE: HR_PAY_SLIP contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_pay_slip_workflow_pay_slip_payslip_refund_flow" module="HR_PAY_SLIP"
WHEN when_execute_seed_contract module="HR_PAY_SLIP"
THEN then_seed_contract_should_hold module="HR_PAY_SLIP"
