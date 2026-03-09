[SCENARIO: BDD-IO_T_VOICEMAIL-SEED-io_t_voicemail_workflow_voicemail_voicemail_lifecycle] TITLE: IO_T_VOICEMAIL contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_voicemail_workflow_voicemail_voicemail_lifecycle" module="IO_T_VOICEMAIL"
WHEN when_execute_seed_contract module="IO_T_VOICEMAIL"
THEN then_seed_contract_should_hold module="IO_T_VOICEMAIL"
