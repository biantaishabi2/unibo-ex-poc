[SCENARIO: BDD-CRM_SALES_TEAM-SEED-crm_sales_team_workflow_sales_team_sales_team_lifecycle] TITLE: CRM_SALES_TEAM contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_sales_team_workflow_sales_team_sales_team_lifecycle" module="CRM_SALES_TEAM"
WHEN when_execute_seed_contract module="CRM_SALES_TEAM"
THEN then_seed_contract_should_hold module="CRM_SALES_TEAM"
