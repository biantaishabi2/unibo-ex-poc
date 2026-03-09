[SCENARIO: BDD-IO_T_CONTACT-SEED-io_t_contact_action_contact_read_read] TITLE: IO_T_CONTACT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_contact_action_contact_read_read" module="IO_T_CONTACT"
WHEN when_execute_seed_contract module="IO_T_CONTACT"
THEN then_seed_contract_should_hold module="IO_T_CONTACT"
