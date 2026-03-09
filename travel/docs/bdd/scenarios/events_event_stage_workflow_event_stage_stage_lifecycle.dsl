[SCENARIO: BDD-EVENTS_EVENT_STAGE-SEED-events_event_stage_workflow_event_stage_stage_lifecycle] TITLE: EVENTS_EVENT_STAGE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="events_event_stage_workflow_event_stage_stage_lifecycle" module="EVENTS_EVENT_STAGE"
WHEN when_execute_seed_contract module="EVENTS_EVENT_STAGE"
THEN then_seed_contract_should_hold module="EVENTS_EVENT_STAGE"
