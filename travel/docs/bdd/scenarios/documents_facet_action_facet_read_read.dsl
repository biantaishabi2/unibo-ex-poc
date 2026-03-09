[SCENARIO: BDD-DOCUMENTS_FACET-SEED-documents_facet_action_facet_read_read] TITLE: DOCUMENTS_FACET contract seed scenario TAGS: seed all
GIVEN given_seed_context id="documents_facet_action_facet_read_read" module="DOCUMENTS_FACET"
WHEN when_execute_seed_contract module="DOCUMENTS_FACET"
THEN then_seed_contract_should_hold module="DOCUMENTS_FACET"
