[SCENARIO: BDD-PLM_ECO-SEED-plm_eco_event_eco_create_plm_eco_created] TITLE: PLM_ECO contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_event_eco_create_plm_eco_created" module="PLM_ECO"
WHEN when_execute_seed_contract module="PLM_ECO"
THEN then_seed_contract_should_hold module="PLM_ECO"
