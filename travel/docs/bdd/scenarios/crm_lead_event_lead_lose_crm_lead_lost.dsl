[SCENARIO: BDD-CRM_LEAD-SEED-crm_lead_event_lead_lose_crm_lead_lost] TITLE: CRM_LEAD contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_lead_event_lead_lose_crm_lead_lost" module="CRM_LEAD"
WHEN when_execute_seed_contract module="CRM_LEAD"
THEN then_seed_contract_should_hold module="CRM_LEAD"
