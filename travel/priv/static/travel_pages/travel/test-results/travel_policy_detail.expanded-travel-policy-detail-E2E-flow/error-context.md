# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_policy_detail.expanded.spec.ts >> travel_policy_detail >> E2E flow
- Location: travel_policy_detail.expanded.spec.ts:898:7

# Error details

```
Error: backend get equals assertion failed: expected UPDATED_1775286437464_xqjeeg_policy_name got policy_name_002
```

# Page snapshot

```yaml
- generic [ref=e2]:
  - banner [ref=e3]:
    - generic [ref=e4]:
      - generic [ref=e5]:
        - link [ref=e6] [cursor=pointer]:
          - /url: /
          - img [ref=e7]
        - paragraph [ref=e8]: v1.7.21
      - generic [ref=e9]:
        - link "@elixirphoenix" [ref=e10] [cursor=pointer]:
          - /url: https://twitter.com/elixirphoenix
        - link "GitHub" [ref=e11] [cursor=pointer]:
          - /url: https://github.com/phoenixframework/phoenix
        - link "Get Started" [ref=e12] [cursor=pointer]:
          - /url: https://hexdocs.pm/phoenix/overview.html
          - text: Get Started →
  - main [ref=e13]:
    - generic "详情" [ref=e15]:
      - navigation "breadcrumb" [ref=e17]:
        - list [ref=e18]:
          - listitem [ref=e19]:
            - generic [ref=e20]: 列表
          - listitem [ref=e21]:
            - img [ref=e22]
          - listitem [ref=e24]:
            - link "详情" [disabled] [ref=e25]
      - generic [ref=e27]:
        - generic [ref=e29]:
          - paragraph [ref=e30]: TravelPolicy
          - paragraph [ref=e31]: 差旅标准政策,定义不同企业、职级、城市等级下的差旅费用上限与超标策略
        - generic [ref=e33]:
          - button "编辑" [ref=e34] [cursor=pointer]
          - button "activate" [ref=e35] [cursor=pointer]
          - button "deactivate" [ref=e36] [cursor=pointer]
          - button "删除" [ref=e37] [cursor=pointer]
      - generic [ref=e39]:
        - heading "基本信息" [level=3] [ref=e41]
        - generic [ref=e43]:
          - generic [ref=e45]:
            - textbox [ref=e47]: UPDATED_1775286437464_xqjeeg_policy_name
            - button [ref=e49] [cursor=pointer]
            - textbox [ref=e52]
            - textbox [ref=e54]
            - textbox [ref=e56]: UPDATED_1775286437464_xqjeeg_season
            - textbox [ref=e58]: "2"
            - textbox [ref=e60]: UPDATED_1775286437464_xqjeeg_cabin_class_limit
            - textbox [ref=e62]: UPDATED_1775286437464_xqjeeg_hotel_star_limit
            - button "require_reason" [ref=e64] [cursor=pointer]:
              - generic: require_reason
            - button "self" [ref=e67] [cursor=pointer]:
              - generic: self
            - textbox [ref=e70]: "2"
            - textbox [ref=e72]
          - generic [ref=e73]:
            - button "取消" [ref=e74] [cursor=pointer]
            - button "保存" [active] [ref=e75] [cursor=pointer]
```

# Test source

```ts
  632 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  633 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  634 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  635 |   }
  636 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
  637 |     await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  638 |   }
  639 |   if (kind === 'form_settled' && selector) {
  640 |     const formLocator = locatorFor(page, selector);
  641 |     const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
  642 |     try {
  643 |       await formLocator.waitFor({ state: 'hidden', timeout });
  644 |     } catch (error) {
  645 |       let settled = false;
  646 |       for (const candidate of fallbackSelectors) {
  647 |         try {
  648 |           await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
  649 |           settled = true;
  650 |           break;
  651 |         } catch (_candidateError) {}
  652 |       }
  653 |       const stillVisible = await formLocator.isVisible().catch(() => false);
  654 |       if (stillVisible && !settled) throw error;
  655 |     }
  656 |     await syncRouteContext(page, ctx);
  657 |   }
  658 |   if (kind === 'url_contains' || kind === 'url_and_root') {
  659 |     const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
  660 |     if (expectedUrl) {
  661 |       try {
  662 |         await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
  663 |       } catch (_e) {
  664 |         await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
  665 |       }
  666 |     }
  667 |     if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  668 |     await syncRouteContext(page, ctx);
  669 |   }
  670 | }
  671 | 
  672 | async function retryBackendAssertion(timeout, task) {
  673 |   const deadline = Date.now() + timeout;
  674 |   let lastError = null;
  675 |   while (Date.now() <= deadline) {
  676 |     try {
  677 |       return await task();
  678 |     } catch (error) {
  679 |       lastError = error;
  680 |       await new Promise((resolve) => setTimeout(resolve, 200));
  681 |     }
  682 |   }
  683 |   throw lastError || new Error('backend assertion timed out');
  684 | }
  685 | 
  686 | async function snapshotPreCreateIds(ctx) {
  687 |   if (ctx.__pre_create_ids) return;
  688 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  689 |   if (!listApiRef) return;
  690 |   try {
  691 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  692 |     if (!listField) return;
  693 |     const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
  694 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  695 |     ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  696 |   } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
  697 | }
  698 | 
  699 | async function runCaseWait(page, ctx, waitKey, covers) {
  700 |   const entries = [];
  701 |   const pushEntry = (entry) => {
  702 |     if (!entry) return;
  703 |     if (!entries.includes(entry)) entries.push(entry);
  704 |   };
  705 |   if (waitKey && waitKey !== '__AUTO__') {
  706 |     pushEntry(__WAIT_CONTRACT[waitKey]);
  707 |   } else if (Array.isArray(covers) && covers.length === 1) {
  708 |     pushEntry(__WAIT_CONTRACT[covers[0]]);
  709 |   }
  710 |   for (const entry of entries) {
  711 |     await runWaitEntry(page, ctx, entry);
  712 |   }
  713 | }
  714 | 
  715 | async function executeBackendAssertion(ctx, assertion) {
  716 |   if (!assertion || !assertion.api) return;
  717 |   const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  718 |   if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  719 |   const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  720 |   if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  721 |   const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  722 |   await retryBackendAssertion(timeout, async () => {
  723 |     if (assertion.api === 'get') {
  724 |       const id = resolveBackendAssertionId(ctx, assertion);
  725 |       const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
  726 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
  727 |       const record = payload?.data?.[field];
  728 |       const actual = readValueAtPath(record, assertion.path || null);
  729 |       if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
  730 |       if (assertion.op === 'equals' || assertion.op === 'field_equals') {
  731 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
> 732 |         if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
      |                                                      ^ Error: backend get equals assertion failed: expected UPDATED_1775286437464_xqjeeg_policy_name got policy_name_002
  733 |       }
  734 |       applyBindings(ctx, assertion.binds, record);
  735 |       refreshDataBindings(ctx);
  736 |       return;
  737 |     }
  738 |     if (assertion.api === 'list') {
  739 |       const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
  740 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
  741 |       const results = payload?.data?.[field]?.results || [];
  742 |       if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
  743 |       if (assertion.op === 'contains_equals') {
  744 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
  745 |         const matched = Array.isArray(results)
  746 |           ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
  747 |           : null;
  748 |         if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
  749 |         applyBindings(ctx, assertion.binds, matched);
  750 |         refreshDataBindings(ctx);
  751 |         return;
  752 |       }
  753 |       if (assertion.op === 'not_contains') {
  754 |         const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
  755 |         const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
  756 |         if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
  757 |       }
  758 |     }
  759 |   });
  760 | }
  761 | 
  762 | async function captureCreatedRecordId(ctx, caseKind, covers) {
  763 |   const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  764 |   if (!isCreate) return;
  765 |   if (ctx.created_record_id) return;
  766 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  767 |   if (!listApiRef) return;
  768 |   try {
  769 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  770 |     if (!listField) return;
  771 |     const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
  772 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  773 |     const allIds = rows.map((r) => r?.id).filter(Boolean);
  774 |     if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
  775 |     const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
  776 |     const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
  777 |     if (matched?.id) {
  778 |       ctx.created_record_id = matched.id;
  779 |       ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  780 |       ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
  781 |       refreshDataBindings(ctx);
  782 |     }
  783 |   } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
  784 | }
  785 | 
  786 | async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  787 |   const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  788 |   for (const entry of entries) {
  789 |     if (!entry) continue;
  790 |     for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
  791 |       if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
  792 |       if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
  793 |       if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
  794 |     }
  795 |     await executeBackendAssertion(ctx, entry.backend);
  796 |   }
  797 | }
  798 | 
  799 | async function runContractCleanup(ctx) {
  800 |   const seedIds = ctx.__seed_ids || new Set();
  801 |   const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  802 |   for (const entry of dynamicQueue) {
  803 |     if (!entry?.id || !entry?.domain || !entry?.entity) continue;
  804 |     if (seedIds.has(entry.id)) continue;
  805 |     try {
  806 |       const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
  807 |       if (!field) continue;
  808 |       await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
  809 |     } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  810 |   }
  811 |   for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
  812 |     if (!item?.api) continue;
  813 |     const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
  814 |     if (!apiRef) continue;
  815 |     const id = resolveCleanupSourceValue(ctx, item.source, item.path);
  816 |     if (id == null || id === '') {
  817 |       if (item.ignore_missing) continue;
  818 |       throw new Error('cleanup source value missing for ' + JSON.stringify(item));
  819 |     }
  820 |     if (seedIds.has(id)) continue;
  821 |     const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
  822 |     if (!field) {
  823 |       if (item.ignore_missing) continue;
  824 |       throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
  825 |     }
  826 |     const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
  827 |     const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  828 |     if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
  829 |       throw new Error('cleanup mutation failed for ' + String(field));
  830 |     }
  831 |   }
  832 | }
```