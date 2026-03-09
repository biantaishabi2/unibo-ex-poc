[SCENARIO: BDD-CRM_SALES_TEAM-SEED-crm_sales_team_action_sales_team_create_create] TITLE: CRM_SALES_TEAM contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_sales_team_action_sales_team_create_create" module="CRM_SALES_TEAM"
WHEN when_execute_seed_contract module="CRM_SALES_TEAM"
THEN then_seed_contract_should_hold module="CRM_SALES_TEAM"
