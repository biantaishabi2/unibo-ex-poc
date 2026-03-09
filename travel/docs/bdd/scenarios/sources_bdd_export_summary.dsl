[SCENARIO: BDD-SOURCES-SEED-sources_bdd_export_summary] TITLE: sources contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sources_bdd_export_summary" module="SOURCES"
WHEN when_execute_seed_contract module="SOURCES"
THEN then_seed_contract_should_hold module="SOURCES"
