[SCENARIO: BDD-PLM_BOM_REVISION-SEED-plm_bom_revision_workflow_bom_revision_bom_activation_sync] TITLE: PLM_BOM_REVISION contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_bom_revision_workflow_bom_revision_bom_activation_sync" module="PLM_BOM_REVISION"
WHEN when_execute_seed_contract module="PLM_BOM_REVISION"
THEN then_seed_contract_should_hold module="PLM_BOM_REVISION"
