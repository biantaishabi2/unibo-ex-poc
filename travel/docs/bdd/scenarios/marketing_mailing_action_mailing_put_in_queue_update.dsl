[SCENARIO: BDD-MARKETING_MAILING-SEED-marketing_mailing_action_mailing_put_in_queue_update] TITLE: MARKETING_MAILING contract seed scenario TAGS: seed all
GIVEN given_seed_context id="marketing_mailing_action_mailing_put_in_queue_update" module="MARKETING_MAILING"
WHEN when_execute_seed_contract module="MARKETING_MAILING"
THEN then_seed_contract_should_hold module="MARKETING_MAILING"
