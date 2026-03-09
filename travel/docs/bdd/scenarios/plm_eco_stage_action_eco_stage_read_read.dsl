[SCENARIO: BDD-PLM_ECO_STAGE-SEED-plm_eco_stage_action_eco_stage_read_read] TITLE: PLM_ECO_STAGE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_stage_action_eco_stage_read_read" module="PLM_ECO_STAGE"
WHEN when_execute_seed_contract module="PLM_ECO_STAGE"
THEN then_seed_contract_should_hold module="PLM_ECO_STAGE"
