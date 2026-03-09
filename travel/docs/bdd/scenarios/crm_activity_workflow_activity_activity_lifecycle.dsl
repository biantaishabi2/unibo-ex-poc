[SCENARIO: BDD-CRM_ACTIVITY-SEED-crm_activity_workflow_activity_activity_lifecycle] TITLE: CRM_ACTIVITY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_activity_workflow_activity_activity_lifecycle" module="CRM_ACTIVITY"
WHEN when_execute_seed_contract module="CRM_ACTIVITY"
THEN then_seed_contract_should_hold module="CRM_ACTIVITY"
