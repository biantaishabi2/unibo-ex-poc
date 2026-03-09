[SCENARIO: BDD-COMMUNICATION_GUEST-SEED-communication_guest_action_guest_read_read] TITLE: COMMUNICATION_GUEST contract seed scenario TAGS: seed all
GIVEN given_seed_context id="communication_guest_action_guest_read_read" module="COMMUNICATION_GUEST"
WHEN when_execute_seed_contract module="COMMUNICATION_GUEST"
THEN then_seed_contract_should_hold module="COMMUNICATION_GUEST"
