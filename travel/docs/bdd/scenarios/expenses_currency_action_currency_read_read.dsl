[SCENARIO: BDD-EXPENSES_CURRENCY-SEED-expenses_currency_action_currency_read_read] TITLE: EXPENSES_CURRENCY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="expenses_currency_action_currency_read_read" module="EXPENSES_CURRENCY"
WHEN when_execute_seed_contract module="EXPENSES_CURRENCY"
THEN then_seed_contract_should_hold module="EXPENSES_CURRENCY"
