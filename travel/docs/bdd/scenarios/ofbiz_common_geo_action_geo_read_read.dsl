[SCENARIO: BDD-OFBIZ_COMMON_GEO-SEED-ofbiz_common_geo_action_geo_read_read] TITLE: OFBIZ_COMMON_GEO contract seed scenario TAGS: seed all
GIVEN given_seed_context id="ofbiz_common_geo_action_geo_read_read" module="OFBIZ_COMMON_GEO"
WHEN when_execute_seed_contract module="OFBIZ_COMMON_GEO"
THEN then_seed_contract_should_hold module="OFBIZ_COMMON_GEO"
