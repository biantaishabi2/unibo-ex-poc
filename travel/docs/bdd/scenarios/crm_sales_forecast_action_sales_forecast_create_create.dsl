[SCENARIO: BDD-CRM_SALES_FORECAST-SEED-crm_sales_forecast_action_sales_forecast_create_create] TITLE: CRM_SALES_FORECAST contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_sales_forecast_action_sales_forecast_create_create" module="CRM_SALES_FORECAST"
WHEN when_execute_seed_contract module="CRM_SALES_FORECAST"
THEN then_seed_contract_should_hold module="CRM_SALES_FORECAST"
