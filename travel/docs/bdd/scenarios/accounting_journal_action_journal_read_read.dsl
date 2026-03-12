[SCENARIO: BDD-ACCOUNTING_JOURNAL-SEED-accounting_journal_action_journal_read_read] TITLE: ACCOUNTING_JOURNAL contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="accounting_journal_action_journal_read_read" module="ACCOUNTING_JOURNAL"
WHEN when_execute_seed_contract module="ACCOUNTING_JOURNAL"
THEN then_seed_contract_should_hold module="ACCOUNTING_JOURNAL"
