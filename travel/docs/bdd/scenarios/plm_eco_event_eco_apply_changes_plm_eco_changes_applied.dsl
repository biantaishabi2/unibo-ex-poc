[SCENARIO: BDD-PLM_ECO-SEED-plm_eco_event_eco_apply_changes_plm_eco_changes_applied] TITLE: PLM_ECO contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_event_eco_apply_changes_plm_eco_changes_applied" module="PLM_ECO"
WHEN when_execute_seed_contract module="PLM_ECO"
THEN then_seed_contract_should_hold module="PLM_ECO"
