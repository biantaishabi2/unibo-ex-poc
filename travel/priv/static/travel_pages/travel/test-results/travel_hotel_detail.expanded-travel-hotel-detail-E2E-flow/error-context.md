# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_hotel_detail.expanded.spec.ts >> travel_hotel_detail >> E2E flow
- Location: travel_hotel_detail.expanded.spec.ts:863:7

# Error details

```
Error: backend get equals assertion failed: expected UPDATED_1775273270415_6z7act_city_id got 
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
        - generic [ref=e28]:
          - generic [ref=e29]:
            - paragraph [ref=e30]: TravelHotel
            - paragraph [ref=e31]: 酒店主数据（Travel 层,来源 OFBiz Product）
          - generic [ref=e32]: inactive
        - generic [ref=e33]:
          - button "编辑" [ref=e34] [cursor=pointer]
          - button "删除" [ref=e35] [cursor=pointer]
      - generic [ref=e37]:
        - heading "基本信息" [level=3] [ref=e39]
        - generic [ref=e42]:
          - generic [ref=e43]:
            - paragraph [ref=e44]: 酒店规范编码
            - paragraph [ref=e45]: hotel_code_003
          - generic [ref=e46]:
            - paragraph [ref=e47]: 酒店名称
            - paragraph [ref=e48]: UPDATED_1775273270415_6z7act_hotel_name
          - generic [ref=e49]:
            - paragraph [ref=e50]: 城市编码冗余（便于兼容检索）
            - paragraph [ref=e51]: UPDATED_1775273270415_6z7act_city_code
          - generic [ref=e52]:
            - paragraph [ref=e53]: 酒店星级
            - paragraph [ref=e54]: UPDATED_1775273270415_6z7act_hotel_star
          - generic [ref=e55]:
            - paragraph [ref=e56]: status
            - paragraph [ref=e57]: inactive
```

# Test source

```ts
  597 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  598 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  599 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  600 |   }
  601 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
  602 |     await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  603 |   }
  604 |   if (kind === 'form_settled' && selector) {
  605 |     const formLocator = locatorFor(page, selector);
  606 |     const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
  607 |     try {
  608 |       await formLocator.waitFor({ state: 'hidden', timeout });
  609 |     } catch (error) {
  610 |       let settled = false;
  611 |       for (const candidate of fallbackSelectors) {
  612 |         try {
  613 |           await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
  614 |           settled = true;
  615 |           break;
  616 |         } catch (_candidateError) {}
  617 |       }
  618 |       const stillVisible = await formLocator.isVisible().catch(() => false);
  619 |       if (stillVisible && !settled) throw error;
  620 |     }
  621 |     await syncRouteContext(page, ctx);
  622 |   }
  623 |   if (kind === 'url_contains' || kind === 'url_and_root') {
  624 |     const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
  625 |     if (expectedUrl) {
  626 |       try {
  627 |         await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
  628 |       } catch (_e) {
  629 |         await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
  630 |       }
  631 |     }
  632 |     if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  633 |     await syncRouteContext(page, ctx);
  634 |   }
  635 | }
  636 | 
  637 | async function retryBackendAssertion(timeout, task) {
  638 |   const deadline = Date.now() + timeout;
  639 |   let lastError = null;
  640 |   while (Date.now() <= deadline) {
  641 |     try {
  642 |       return await task();
  643 |     } catch (error) {
  644 |       lastError = error;
  645 |       await new Promise((resolve) => setTimeout(resolve, 200));
  646 |     }
  647 |   }
  648 |   throw lastError || new Error('backend assertion timed out');
  649 | }
  650 | 
  651 | async function snapshotPreCreateIds(ctx) {
  652 |   if (ctx.__pre_create_ids) return;
  653 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  654 |   if (!listApiRef) return;
  655 |   try {
  656 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  657 |     if (!listField) return;
  658 |     const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
  659 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  660 |     ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  661 |   } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
  662 | }
  663 | 
  664 | async function runCaseWait(page, ctx, waitKey, covers) {
  665 |   const entries = [];
  666 |   const pushEntry = (entry) => {
  667 |     if (!entry) return;
  668 |     if (!entries.includes(entry)) entries.push(entry);
  669 |   };
  670 |   if (waitKey && waitKey !== '__AUTO__') {
  671 |     pushEntry(__WAIT_CONTRACT[waitKey]);
  672 |   } else if (Array.isArray(covers) && covers.length === 1) {
  673 |     pushEntry(__WAIT_CONTRACT[covers[0]]);
  674 |   }
  675 |   for (const entry of entries) {
  676 |     await runWaitEntry(page, ctx, entry);
  677 |   }
  678 | }
  679 | 
  680 | async function executeBackendAssertion(ctx, assertion) {
  681 |   if (!assertion || !assertion.api) return;
  682 |   const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  683 |   if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  684 |   const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  685 |   if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  686 |   const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  687 |   await retryBackendAssertion(timeout, async () => {
  688 |     if (assertion.api === 'get') {
  689 |       const id = resolveBackendAssertionId(ctx, assertion);
  690 |       const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
  691 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
  692 |       const record = payload?.data?.[field];
  693 |       const actual = readValueAtPath(record, assertion.path || null);
  694 |       if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
  695 |       if (assertion.op === 'equals' || assertion.op === 'field_equals') {
  696 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
> 697 |         if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
      |                                                      ^ Error: backend get equals assertion failed: expected UPDATED_1775273270415_6z7act_city_id got 
  698 |       }
  699 |       applyBindings(ctx, assertion.binds, record);
  700 |       refreshDataBindings(ctx);
  701 |       return;
  702 |     }
  703 |     if (assertion.api === 'list') {
  704 |       const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
  705 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
  706 |       const results = payload?.data?.[field]?.results || [];
  707 |       if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
  708 |       if (assertion.op === 'contains_equals') {
  709 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
  710 |         const matched = Array.isArray(results)
  711 |           ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
  712 |           : null;
  713 |         if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
  714 |         applyBindings(ctx, assertion.binds, matched);
  715 |         refreshDataBindings(ctx);
  716 |         return;
  717 |       }
  718 |       if (assertion.op === 'not_contains') {
  719 |         const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
  720 |         const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
  721 |         if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
  722 |       }
  723 |     }
  724 |   });
  725 | }
  726 | 
  727 | async function captureCreatedRecordId(ctx, caseKind, covers) {
  728 |   const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  729 |   if (!isCreate) return;
  730 |   if (ctx.created_record_id) return;
  731 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  732 |   if (!listApiRef) return;
  733 |   try {
  734 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  735 |     if (!listField) return;
  736 |     const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
  737 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  738 |     const allIds = rows.map((r) => r?.id).filter(Boolean);
  739 |     if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
  740 |     const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
  741 |     const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
  742 |     if (matched?.id) {
  743 |       ctx.created_record_id = matched.id;
  744 |       ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  745 |       ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
  746 |       refreshDataBindings(ctx);
  747 |     }
  748 |   } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
  749 | }
  750 | 
  751 | async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  752 |   const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  753 |   for (const entry of entries) {
  754 |     if (!entry) continue;
  755 |     for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
  756 |       if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
  757 |       if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
  758 |       if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
  759 |     }
  760 |     await executeBackendAssertion(ctx, entry.backend);
  761 |   }
  762 | }
  763 | 
  764 | async function runContractCleanup(ctx) {
  765 |   const seedIds = ctx.__seed_ids || new Set();
  766 |   const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  767 |   for (const entry of dynamicQueue) {
  768 |     if (!entry?.id || !entry?.domain || !entry?.entity) continue;
  769 |     if (seedIds.has(entry.id)) continue;
  770 |     try {
  771 |       const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
  772 |       if (!field) continue;
  773 |       await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
  774 |     } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  775 |   }
  776 |   for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
  777 |     if (!item?.api) continue;
  778 |     const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
  779 |     if (!apiRef) continue;
  780 |     const id = resolveCleanupSourceValue(ctx, item.source, item.path);
  781 |     if (id == null || id === '') {
  782 |       if (item.ignore_missing) continue;
  783 |       throw new Error('cleanup source value missing for ' + JSON.stringify(item));
  784 |     }
  785 |     if (seedIds.has(id)) continue;
  786 |     const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
  787 |     if (!field) {
  788 |       if (item.ignore_missing) continue;
  789 |       throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
  790 |     }
  791 |     const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
  792 |     const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  793 |     if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
  794 |       throw new Error('cleanup mutation failed for ' + String(field));
  795 |     }
  796 |   }
  797 | }
```