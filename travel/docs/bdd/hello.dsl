[SCENARIO: HELLO-001] TITLE: hello world TAGS: integration
GIVEN create_temp_dir key="hello"
WHEN noop
THEN assert_noop
