[SCENARIO: BDD-CRM_CONTACT_PHONE-SEED-crm_contact_phone_action_contact_phone_create_create] TITLE: CRM_CONTACT_PHONE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="crm_contact_phone_action_contact_phone_create_create" module="CRM_CONTACT_PHONE"
WHEN when_execute_seed_contract module="CRM_CONTACT_PHONE"
THEN then_seed_contract_should_hold module="CRM_CONTACT_PHONE"
