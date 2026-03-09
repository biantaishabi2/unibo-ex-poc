[SCENARIO: BDD-PLM_ECO_TAG-SEED-plm_eco_tag_action_eco_tag_create_create] TITLE: PLM_ECO_TAG contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_tag_action_eco_tag_create_create" module="PLM_ECO_TAG"
WHEN when_execute_seed_contract module="PLM_ECO_TAG"
THEN then_seed_contract_should_hold module="PLM_ECO_TAG"
