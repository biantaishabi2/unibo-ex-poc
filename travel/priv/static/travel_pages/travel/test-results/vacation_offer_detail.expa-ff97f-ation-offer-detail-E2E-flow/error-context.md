# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: vacation_offer_detail.expanded.spec.ts >> vacation_offer_detail >> E2E flow
- Location: vacation_offer_detail.expanded.spec.ts:1216:7

# Error details

```
Error: backend get equals assertion failed: expected UPDATED_1775257572305_sw31o8_departure_city_ref_id got 
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
    - generic [ref=e15]:
      - link "← 列表" [ref=e17] [cursor=pointer]:
        - /url: /pages
      - generic "详情" [ref=e18]:
        - navigation "breadcrumb" [ref=e20]:
          - list [ref=e21]:
            - listitem [ref=e22]:
              - generic [ref=e23]: 列表
            - listitem [ref=e24]:
              - img [ref=e25]
            - listitem [ref=e27]:
              - link "详情" [disabled] [ref=e28]
        - generic [ref=e30]:
          - generic [ref=e32]:
            - paragraph [ref=e33]: VacationOffer
            - paragraph [ref=e34]: 度假可售 offer,承载套餐、出发日期和预订规则快照
          - generic [ref=e36]:
            - button "编辑" [ref=e37] [cursor=pointer]
            - button "deactivate" [ref=e38] [cursor=pointer]
            - button "expire" [ref=e39] [cursor=pointer]
            - button "删除" [ref=e40] [cursor=pointer]
        - generic [ref=e42]:
          - heading "基本信息" [level=3] [ref=e44]
          - generic [ref=e47]:
            - generic [ref=e48]:
              - paragraph [ref=e49]: 供应商编码
              - paragraph
            - generic [ref=e50]:
              - paragraph [ref=e51]: 套餐编码
              - paragraph
            - generic [ref=e52]:
              - paragraph [ref=e53]: 套餐名称
              - paragraph
            - generic [ref=e54]:
              - paragraph [ref=e55]: 套餐类型
              - paragraph
            - generic [ref=e56]:
              - paragraph [ref=e57]: 出发城市编码
              - paragraph
            - generic [ref=e58]:
              - paragraph [ref=e59]: 目的地编码
              - paragraph
            - generic [ref=e60]:
              - paragraph [ref=e61]: 出行开始日期
              - paragraph
            - generic [ref=e62]:
              - paragraph [ref=e63]: 出行结束日期
              - paragraph
            - generic [ref=e64]:
              - paragraph [ref=e65]: 对客展示价快照
              - paragraph
            - generic [ref=e66]:
              - paragraph [ref=e67]: 结算价快照
              - paragraph
            - generic [ref=e68]:
              - paragraph [ref=e69]: currency
              - paragraph
            - generic [ref=e70]:
              - paragraph [ref=e71]: 可售库存快照
              - paragraph
            - generic [ref=e72]:
              - paragraph [ref=e73]: 预订规则快照
              - paragraph
            - generic [ref=e74]:
              - paragraph [ref=e75]: 取消规则快照
              - paragraph
            - generic [ref=e76]:
              - paragraph [ref=e77]: sale_status
              - paragraph
```

# Test source

```ts
  950  |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  951  |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  952  |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  953  |   }
  954  |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
  955  |     await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  956  |   }
  957  |   if (kind === 'form_settled' && selector) {
  958  |     const formLocator = locatorFor(page, selector);
  959  |     const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
  960  |     try {
  961  |       await formLocator.waitFor({ state: 'hidden', timeout });
  962  |     } catch (error) {
  963  |       let settled = false;
  964  |       for (const candidate of fallbackSelectors) {
  965  |         try {
  966  |           await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
  967  |           settled = true;
  968  |           break;
  969  |         } catch (_candidateError) {}
  970  |       }
  971  |       const stillVisible = await formLocator.isVisible().catch(() => false);
  972  |       if (stillVisible && !settled) throw error;
  973  |     }
  974  |     await syncRouteContext(page, ctx);
  975  |   }
  976  |   if (kind === 'url_contains' || kind === 'url_and_root') {
  977  |     const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
  978  |     if (expectedUrl) {
  979  |       try {
  980  |         await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
  981  |       } catch (_e) {
  982  |         await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
  983  |       }
  984  |     }
  985  |     if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  986  |     await syncRouteContext(page, ctx);
  987  |   }
  988  | }
  989  | 
  990  | async function retryBackendAssertion(timeout, task) {
  991  |   const deadline = Date.now() + timeout;
  992  |   let lastError = null;
  993  |   while (Date.now() <= deadline) {
  994  |     try {
  995  |       return await task();
  996  |     } catch (error) {
  997  |       lastError = error;
  998  |       await new Promise((resolve) => setTimeout(resolve, 200));
  999  |     }
  1000 |   }
  1001 |   throw lastError || new Error('backend assertion timed out');
  1002 | }
  1003 | 
  1004 | async function snapshotPreCreateIds(ctx) {
  1005 |   if (ctx.__pre_create_ids) return;
  1006 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1007 |   if (!listApiRef) return;
  1008 |   try {
  1009 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1010 |     if (!listField) return;
  1011 |     const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
  1012 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1013 |     ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  1014 |   } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
  1015 | }
  1016 | 
  1017 | async function runCaseWait(page, ctx, waitKey, covers) {
  1018 |   const entries = [];
  1019 |   const pushEntry = (entry) => {
  1020 |     if (!entry) return;
  1021 |     if (!entries.includes(entry)) entries.push(entry);
  1022 |   };
  1023 |   if (waitKey && waitKey !== '__AUTO__') {
  1024 |     pushEntry(__WAIT_CONTRACT[waitKey]);
  1025 |   } else if (Array.isArray(covers) && covers.length === 1) {
  1026 |     pushEntry(__WAIT_CONTRACT[covers[0]]);
  1027 |   }
  1028 |   for (const entry of entries) {
  1029 |     await runWaitEntry(page, ctx, entry);
  1030 |   }
  1031 | }
  1032 | 
  1033 | async function executeBackendAssertion(ctx, assertion) {
  1034 |   if (!assertion || !assertion.api) return;
  1035 |   const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  1036 |   if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  1037 |   const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  1038 |   if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  1039 |   const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  1040 |   await retryBackendAssertion(timeout, async () => {
  1041 |     if (assertion.api === 'get') {
  1042 |       const id = resolveBackendAssertionId(ctx, assertion);
  1043 |       const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
  1044 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
  1045 |       const record = payload?.data?.[field];
  1046 |       const actual = readValueAtPath(record, assertion.path || null);
  1047 |       if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
  1048 |       if (assertion.op === 'equals' || assertion.op === 'field_equals') {
  1049 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
> 1050 |         if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
       |                                                      ^ Error: backend get equals assertion failed: expected UPDATED_1775257572305_sw31o8_departure_city_ref_id got 
  1051 |       }
  1052 |       applyBindings(ctx, assertion.binds, record);
  1053 |       refreshDataBindings(ctx);
  1054 |       return;
  1055 |     }
  1056 |     if (assertion.api === 'list') {
  1057 |       const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
  1058 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
  1059 |       const results = payload?.data?.[field]?.results || [];
  1060 |       if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
  1061 |       if (assertion.op === 'contains_equals') {
  1062 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
  1063 |         const matched = Array.isArray(results)
  1064 |           ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
  1065 |           : null;
  1066 |         if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
  1067 |         applyBindings(ctx, assertion.binds, matched);
  1068 |         refreshDataBindings(ctx);
  1069 |         return;
  1070 |       }
  1071 |       if (assertion.op === 'not_contains') {
  1072 |         const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
  1073 |         const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
  1074 |         if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
  1075 |       }
  1076 |     }
  1077 |   });
  1078 | }
  1079 | 
  1080 | async function captureCreatedRecordId(ctx, caseKind, covers) {
  1081 |   const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  1082 |   if (!isCreate) return;
  1083 |   if (ctx.created_record_id) return;
  1084 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1085 |   if (!listApiRef) return;
  1086 |   try {
  1087 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1088 |     if (!listField) return;
  1089 |     const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
  1090 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1091 |     const allIds = rows.map((r) => r?.id).filter(Boolean);
  1092 |     if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
  1093 |     const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
  1094 |     const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
  1095 |     if (matched?.id) {
  1096 |       ctx.created_record_id = matched.id;
  1097 |       ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  1098 |       ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
  1099 |       refreshDataBindings(ctx);
  1100 |     }
  1101 |   } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
  1102 | }
  1103 | 
  1104 | async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  1105 |   const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  1106 |   for (const entry of entries) {
  1107 |     if (!entry) continue;
  1108 |     for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
  1109 |       if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
  1110 |       if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
  1111 |       if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
  1112 |     }
  1113 |     await executeBackendAssertion(ctx, entry.backend);
  1114 |   }
  1115 | }
  1116 | 
  1117 | async function runContractCleanup(ctx) {
  1118 |   const seedIds = ctx.__seed_ids || new Set();
  1119 |   const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  1120 |   for (const entry of dynamicQueue) {
  1121 |     if (!entry?.id || !entry?.domain || !entry?.entity) continue;
  1122 |     if (seedIds.has(entry.id)) continue;
  1123 |     try {
  1124 |       const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
  1125 |       if (!field) continue;
  1126 |       await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
  1127 |     } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  1128 |   }
  1129 |   for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
  1130 |     if (!item?.api) continue;
  1131 |     const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
  1132 |     if (!apiRef) continue;
  1133 |     const id = resolveCleanupSourceValue(ctx, item.source, item.path);
  1134 |     if (id == null || id === '') {
  1135 |       if (item.ignore_missing) continue;
  1136 |       throw new Error('cleanup source value missing for ' + JSON.stringify(item));
  1137 |     }
  1138 |     if (seedIds.has(id)) continue;
  1139 |     const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
  1140 |     if (!field) {
  1141 |       if (item.ignore_missing) continue;
  1142 |       throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
  1143 |     }
  1144 |     const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
  1145 |     const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  1146 |     if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
  1147 |       throw new Error('cleanup mutation failed for ' + String(field));
  1148 |     }
  1149 |   }
  1150 | }
```