[SCENARIO: BDD-PLM_ECO-SEED-plm_eco_event_eco_rebase_plm_eco_rebased] TITLE: PLM_ECO contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_event_eco_rebase_plm_eco_rebased" module="PLM_ECO"
WHEN when_execute_seed_contract module="PLM_ECO"
THEN then_seed_contract_should_hold module="PLM_ECO"
