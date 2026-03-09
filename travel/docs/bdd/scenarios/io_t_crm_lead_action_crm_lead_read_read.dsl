[SCENARIO: BDD-IO_T_CRM_LEAD-SEED-io_t_crm_lead_action_crm_lead_read_read] TITLE: IO_T_CRM_LEAD contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_crm_lead_action_crm_lead_read_read" module="IO_T_CRM_LEAD"
WHEN when_execute_seed_contract module="IO_T_CRM_LEAD"
THEN then_seed_contract_should_hold module="IO_T_CRM_LEAD"
