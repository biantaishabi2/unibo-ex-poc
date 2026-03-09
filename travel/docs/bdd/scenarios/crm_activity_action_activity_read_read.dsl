[SCENARIO: BDD-CRM_ACTIVITY-SEED-crm_activity_action_activity_read_read] TITLE: CRM_ACTIVITY contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_activity_action_activity_read_read" module="CRM_ACTIVITY"
WHEN when_execute_seed_contract module="CRM_ACTIVITY"
THEN then_seed_contract_should_hold module="CRM_ACTIVITY"
