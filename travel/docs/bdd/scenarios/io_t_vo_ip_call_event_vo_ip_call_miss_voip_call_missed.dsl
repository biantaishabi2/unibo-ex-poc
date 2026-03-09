[SCENARIO: BDD-IO_T_VO_IP_CALL-SEED-io_t_vo_ip_call_event_vo_ip_call_miss_voip_call_missed] TITLE: IO_T_VO_IP_CALL contract seed scenario TAGS: seed all
GIVEN given_seed_context id="io_t_vo_ip_call_event_vo_ip_call_miss_voip_call_missed" module="IO_T_VO_IP_CALL"
WHEN when_execute_seed_contract module="IO_T_VO_IP_CALL"
THEN then_seed_contract_should_hold module="IO_T_VO_IP_CALL"
