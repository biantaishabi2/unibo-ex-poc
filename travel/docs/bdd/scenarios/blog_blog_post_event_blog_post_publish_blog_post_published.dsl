[SCENARIO: BDD-BLOG_BLOG_POST-SEED-blog_blog_post_event_blog_post_publish_blog_post_published] TITLE: BLOG_BLOG_POST contract seed scenario TAGS: seed all
GIVEN given_seed_context id="blog_blog_post_event_blog_post_publish_blog_post_published" module="BLOG_BLOG_POST"
WHEN when_execute_seed_contract module="BLOG_BLOG_POST"
THEN then_seed_contract_should_hold module="BLOG_BLOG_POST"
