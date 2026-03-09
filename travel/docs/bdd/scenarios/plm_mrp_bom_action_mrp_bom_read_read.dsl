[SCENARIO: BDD-PLM_MRP_BOM-SEED-plm_mrp_bom_action_mrp_bom_read_read] TITLE: PLM_MRP_BOM contract seed scenario TAGS: seed all
GIVEN given_seed_context id="plm_mrp_bom_action_mrp_bom_read_read" module="PLM_MRP_BOM"
WHEN when_execute_seed_contract module="PLM_MRP_BOM"
THEN then_seed_contract_should_hold module="PLM_MRP_BOM"
