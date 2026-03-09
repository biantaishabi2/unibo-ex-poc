[SCENARIO: BDD-EVENTS_EVENT_TYPE-SEED-events_event_type_action_event_type_create_create] TITLE: EVENTS_EVENT_TYPE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="events_event_type_action_event_type_create_create" module="EVENTS_EVENT_TYPE"
WHEN when_execute_seed_contract module="EVENTS_EVENT_TYPE"
THEN then_seed_contract_should_hold module="EVENTS_EVENT_TYPE"
