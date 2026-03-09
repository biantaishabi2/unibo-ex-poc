[SCENARIO: BDD-EVENTS_EVENT_BOOTH-SEED-events_event_booth_action_event_booth_read_read] TITLE: EVENTS_EVENT_BOOTH contract seed scenario TAGS: seed all
GIVEN given_seed_context id="events_event_booth_action_event_booth_read_read" module="EVENTS_EVENT_BOOTH"
WHEN when_execute_seed_contract module="EVENTS_EVENT_BOOTH"
THEN then_seed_contract_should_hold module="EVENTS_EVENT_BOOTH"
