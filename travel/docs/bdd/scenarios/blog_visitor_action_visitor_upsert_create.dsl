[SCENARIO: BDD-BLOG_VISITOR-SEED-blog_visitor_action_visitor_upsert_create] TITLE: BLOG_VISITOR contract seed scenario TAGS: seed all
GIVEN given_seed_context id="blog_visitor_action_visitor_upsert_create" module="BLOG_VISITOR"
WHEN when_execute_seed_contract module="BLOG_VISITOR"
THEN then_seed_contract_should_hold module="BLOG_VISITOR"
