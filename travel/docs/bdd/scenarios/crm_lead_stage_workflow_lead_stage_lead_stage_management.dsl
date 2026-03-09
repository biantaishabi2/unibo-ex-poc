[SCENARIO: BDD-CRM_LEAD_STAGE-SEED-crm_lead_stage_workflow_lead_stage_lead_stage_management] TITLE: CRM_LEAD_STAGE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_lead_stage_workflow_lead_stage_lead_stage_management" module="CRM_LEAD_STAGE"
WHEN when_execute_seed_contract module="CRM_LEAD_STAGE"
THEN then_seed_contract_should_hold module="CRM_LEAD_STAGE"
