[SCENARIO: BDD-HR_TRAINING-SEED-hr_training_action_training_create_create] TITLE: HR_TRAINING contract seed scenario TAGS: seed all
GIVEN given_seed_context id="hr_training_action_training_create_create" module="HR_TRAINING"
WHEN when_execute_seed_contract module="HR_TRAINING"
THEN then_seed_contract_should_hold module="HR_TRAINING"
