[SCENARIO: BDD-EVENTS_EVENT-SEED-events_event_action_event_complete_update] TITLE: EVENTS_EVENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="events_event_action_event_complete_update" module="EVENTS_EVENT"
WHEN when_execute_seed_contract module="EVENTS_EVENT"
THEN then_seed_contract_should_hold module="EVENTS_EVENT"
