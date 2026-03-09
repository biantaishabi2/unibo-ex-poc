[SCENARIO: BDD-CALENDAR_CALENDAR-SEED-calendar_calendar_action_calendar_read_read] TITLE: CALENDAR_CALENDAR contract seed scenario TAGS: seed all
GIVEN given_seed_context id="calendar_calendar_action_calendar_read_read" module="CALENDAR_CALENDAR"
WHEN when_execute_seed_contract module="CALENDAR_CALENDAR"
THEN then_seed_contract_should_hold module="CALENDAR_CALENDAR"
