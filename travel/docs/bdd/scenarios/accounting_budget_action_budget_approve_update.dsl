[SCENARIO: BDD-ACCOUNTING_BUDGET-SEED-accounting_budget_action_budget_approve_update] TITLE: ACCOUNTING_BUDGET contract seed scenario TAGS: seed all
GIVEN given_seed_context id="accounting_budget_action_budget_approve_update" module="ACCOUNTING_BUDGET"
WHEN when_execute_seed_contract module="ACCOUNTING_BUDGET"
THEN then_seed_contract_should_hold module="ACCOUNTING_BUDGET"
