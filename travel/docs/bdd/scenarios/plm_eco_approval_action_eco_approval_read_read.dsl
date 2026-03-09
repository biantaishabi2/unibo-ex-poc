[SCENARIO: BDD-PLM_ECO_APPROVAL-SEED-plm_eco_approval_action_eco_approval_read_read] TITLE: PLM_ECO_APPROVAL contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_eco_approval_action_eco_approval_read_read" module="PLM_ECO_APPROVAL"
WHEN when_execute_seed_contract module="PLM_ECO_APPROVAL"
THEN then_seed_contract_should_hold module="PLM_ECO_APPROVAL"
