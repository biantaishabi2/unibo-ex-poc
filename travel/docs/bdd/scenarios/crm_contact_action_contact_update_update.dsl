[SCENARIO: BDD-CRM_CONTACT-SEED-crm_contact_action_contact_update_update] TITLE: CRM_CONTACT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_contact_action_contact_update_update" module="CRM_CONTACT"
WHEN when_execute_seed_contract module="CRM_CONTACT"
THEN then_seed_contract_should_hold module="CRM_CONTACT"
