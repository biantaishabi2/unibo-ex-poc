[SCENARIO: BDD-EXPENSES_ACCOUNT-SEED-expenses_account_action_account_read_read] TITLE: EXPENSES_ACCOUNT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="expenses_account_action_account_read_read" module="EXPENSES_ACCOUNT"
WHEN when_execute_seed_contract module="EXPENSES_ACCOUNT"
THEN then_seed_contract_should_hold module="EXPENSES_ACCOUNT"
