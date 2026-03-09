[SCENARIO: BDD-CRM_LEAD-SEED-crm_lead_workflow_lead_lead_lifecycle] TITLE: CRM_LEAD contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_lead_workflow_lead_lead_lifecycle" module="CRM_LEAD"
WHEN when_execute_seed_contract module="CRM_LEAD"
THEN then_seed_contract_should_hold module="CRM_LEAD"
