[SCENARIO: BDD-SCHEDULING_DEPARTMENT-SEED-action_department_read_read] TITLE: SCHEDULING_DEPARTMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="action_department_read_read" module="SCHEDULING_DEPARTMENT"
WHEN when_execute_seed_contract module="SCHEDULING_DEPARTMENT"
THEN then_seed_contract_should_hold module="SCHEDULING_DEPARTMENT"


[SCENARIO: BDD-SCHEDULING_DEPARTMENT-SEED-graphql_contract_department] TITLE: SCHEDULING_DEPARTMENT contract seed scenario TAGS: seed graphql_contract
GIVEN given_seed_context id="graphql_contract_department" module="SCHEDULING_DEPARTMENT"
WHEN when_execute_seed_contract module="SCHEDULING_DEPARTMENT"
THEN then_seed_contract_should_hold module="SCHEDULING_DEPARTMENT"
