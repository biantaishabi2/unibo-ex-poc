# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: train_offer_detail.expanded.spec.ts >> train_offer_detail >> E2E flow
- Location: train_offer_detail.expanded.spec.ts:1235:7

# Error details

```
Error: backend get equals assertion failed: expected UPDATED_1775225358562_w0hqus_booking_rules_snapshot got Lorem ipsum booking_rules_snapshot
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
            - paragraph [ref=e33]: TrainOffer
            - paragraph [ref=e34]: 火车票可售 offer,承载车次、席别、候补和退改规则快照
          - generic [ref=e36]:
            - button "编辑" [ref=e37] [cursor=pointer]
            - button "activate" [ref=e38] [cursor=pointer]
            - button "删除" [ref=e39] [cursor=pointer]
        - generic [ref=e41]:
          - heading "基本信息" [level=3] [ref=e43]
          - generic [ref=e45]:
            - generic [ref=e47]:
              - textbox [ref=e49]
              - textbox [ref=e51]
              - textbox [ref=e53]
              - textbox [ref=e55]
              - textbox [ref=e57]
              - textbox [ref=e59]: UPDATED_1775225358562_w0hqus_departure_station_ref_id
              - textbox [ref=e61]: UPDATED_1775225358562_w0hqus_departure_station_name
              - textbox [ref=e63]
              - textbox [ref=e65]: UPDATED_1775225358562_w0hqus_arrival_station_ref_id
              - textbox [ref=e67]: UPDATED_1775225358562_w0hqus_arrival_station_name
              - textbox [ref=e69]
              - textbox [ref=e71]: 2026-02-01T09:00:00Z
              - textbox [ref=e73]: 2026-02-01T09:00:00Z
              - textbox [ref=e75]: UPDATED_1775225358562_w0hqus_seat_class
              - textbox [ref=e77]
              - switch [disabled] [ref=e78]
              - button "waitlist_only" [disabled] [ref=e80]:
                - generic: waitlist_only
              - switch [disabled] [ref=e82]
              - textbox [ref=e84]: "200.00"
              - textbox [ref=e86]: "200.00"
              - textbox [ref=e88]: UPDATED_1775225358562_w0hqus_currency
              - textbox [ref=e89]: UPDATED_1775225358562_w0hqus_booking_rules_snapshot
              - textbox [ref=e90]: UPDATED_1775225358562_w0hqus_change_rules_snapshot
              - textbox [ref=e91]: UPDATED_1775225358562_w0hqus_refund_rules_snapshot
              - button [disabled] [ref=e93]
            - generic [ref=e95]:
              - button "取消" [disabled]
              - button "保存" [disabled]
```

# Test source

```ts
  969  |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  970  |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  971  |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  972  |   }
  973  |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
  974  |     await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  975  |   }
  976  |   if (kind === 'form_settled' && selector) {
  977  |     const formLocator = locatorFor(page, selector);
  978  |     const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
  979  |     try {
  980  |       await formLocator.waitFor({ state: 'hidden', timeout });
  981  |     } catch (error) {
  982  |       let settled = false;
  983  |       for (const candidate of fallbackSelectors) {
  984  |         try {
  985  |           await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
  986  |           settled = true;
  987  |           break;
  988  |         } catch (_candidateError) {}
  989  |       }
  990  |       const stillVisible = await formLocator.isVisible().catch(() => false);
  991  |       if (stillVisible && !settled) throw error;
  992  |     }
  993  |     await syncRouteContext(page, ctx);
  994  |   }
  995  |   if (kind === 'url_contains' || kind === 'url_and_root') {
  996  |     const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
  997  |     if (expectedUrl) {
  998  |       try {
  999  |         await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
  1000 |       } catch (_e) {
  1001 |         await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
  1002 |       }
  1003 |     }
  1004 |     if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  1005 |     await syncRouteContext(page, ctx);
  1006 |   }
  1007 | }
  1008 | 
  1009 | async function retryBackendAssertion(timeout, task) {
  1010 |   const deadline = Date.now() + timeout;
  1011 |   let lastError = null;
  1012 |   while (Date.now() <= deadline) {
  1013 |     try {
  1014 |       return await task();
  1015 |     } catch (error) {
  1016 |       lastError = error;
  1017 |       await new Promise((resolve) => setTimeout(resolve, 200));
  1018 |     }
  1019 |   }
  1020 |   throw lastError || new Error('backend assertion timed out');
  1021 | }
  1022 | 
  1023 | async function snapshotPreCreateIds(ctx) {
  1024 |   if (ctx.__pre_create_ids) return;
  1025 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1026 |   if (!listApiRef) return;
  1027 |   try {
  1028 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1029 |     if (!listField) return;
  1030 |     const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
  1031 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1032 |     ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  1033 |   } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
  1034 | }
  1035 | 
  1036 | async function runCaseWait(page, ctx, waitKey, covers) {
  1037 |   const entries = [];
  1038 |   const pushEntry = (entry) => {
  1039 |     if (!entry) return;
  1040 |     if (!entries.includes(entry)) entries.push(entry);
  1041 |   };
  1042 |   if (waitKey && waitKey !== '__AUTO__') {
  1043 |     pushEntry(__WAIT_CONTRACT[waitKey]);
  1044 |   } else if (Array.isArray(covers) && covers.length === 1) {
  1045 |     pushEntry(__WAIT_CONTRACT[covers[0]]);
  1046 |   }
  1047 |   for (const entry of entries) {
  1048 |     await runWaitEntry(page, ctx, entry);
  1049 |   }
  1050 | }
  1051 | 
  1052 | async function executeBackendAssertion(ctx, assertion) {
  1053 |   if (!assertion || !assertion.api) return;
  1054 |   const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  1055 |   if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  1056 |   const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  1057 |   if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  1058 |   const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  1059 |   await retryBackendAssertion(timeout, async () => {
  1060 |     if (assertion.api === 'get') {
  1061 |       const id = resolveBackendAssertionId(ctx, assertion);
  1062 |       const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
  1063 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
  1064 |       const record = payload?.data?.[field];
  1065 |       const actual = readValueAtPath(record, assertion.path || null);
  1066 |       if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
  1067 |       if (assertion.op === 'equals' || assertion.op === 'field_equals') {
  1068 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
> 1069 |         if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
       |                                                      ^ Error: backend get equals assertion failed: expected UPDATED_1775225358562_w0hqus_booking_rules_snapshot got Lorem ipsum booking_rules_snapshot
  1070 |       }
  1071 |       applyBindings(ctx, assertion.binds, record);
  1072 |       refreshDataBindings(ctx);
  1073 |       return;
  1074 |     }
  1075 |     if (assertion.api === 'list') {
  1076 |       const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
  1077 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
  1078 |       const results = payload?.data?.[field]?.results || [];
  1079 |       if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
  1080 |       if (assertion.op === 'contains_equals') {
  1081 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
  1082 |         const matched = Array.isArray(results)
  1083 |           ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
  1084 |           : null;
  1085 |         if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
  1086 |         applyBindings(ctx, assertion.binds, matched);
  1087 |         refreshDataBindings(ctx);
  1088 |         return;
  1089 |       }
  1090 |       if (assertion.op === 'not_contains') {
  1091 |         const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
  1092 |         const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
  1093 |         if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
  1094 |       }
  1095 |     }
  1096 |   });
  1097 | }
  1098 | 
  1099 | async function captureCreatedRecordId(ctx, caseKind, covers) {
  1100 |   const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  1101 |   if (!isCreate) return;
  1102 |   if (ctx.created_record_id) return;
  1103 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1104 |   if (!listApiRef) return;
  1105 |   try {
  1106 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1107 |     if (!listField) return;
  1108 |     const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
  1109 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1110 |     const allIds = rows.map((r) => r?.id).filter(Boolean);
  1111 |     if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
  1112 |     const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
  1113 |     const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
  1114 |     if (matched?.id) {
  1115 |       ctx.created_record_id = matched.id;
  1116 |       ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  1117 |       ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
  1118 |       refreshDataBindings(ctx);
  1119 |     }
  1120 |   } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
  1121 | }
  1122 | 
  1123 | async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  1124 |   const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  1125 |   for (const entry of entries) {
  1126 |     if (!entry) continue;
  1127 |     for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
  1128 |       if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
  1129 |       if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
  1130 |       if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
  1131 |     }
  1132 |     await executeBackendAssertion(ctx, entry.backend);
  1133 |   }
  1134 | }
  1135 | 
  1136 | async function runContractCleanup(ctx) {
  1137 |   const seedIds = ctx.__seed_ids || new Set();
  1138 |   const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  1139 |   for (const entry of dynamicQueue) {
  1140 |     if (!entry?.id || !entry?.domain || !entry?.entity) continue;
  1141 |     if (seedIds.has(entry.id)) continue;
  1142 |     try {
  1143 |       const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
  1144 |       if (!field) continue;
  1145 |       await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
  1146 |     } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  1147 |   }
  1148 |   for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
  1149 |     if (!item?.api) continue;
  1150 |     const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
  1151 |     if (!apiRef) continue;
  1152 |     const id = resolveCleanupSourceValue(ctx, item.source, item.path);
  1153 |     if (id == null || id === '') {
  1154 |       if (item.ignore_missing) continue;
  1155 |       throw new Error('cleanup source value missing for ' + JSON.stringify(item));
  1156 |     }
  1157 |     if (seedIds.has(id)) continue;
  1158 |     const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
  1159 |     if (!field) {
  1160 |       if (item.ignore_missing) continue;
  1161 |       throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
  1162 |     }
  1163 |     const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
  1164 |     const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  1165 |     if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
  1166 |       throw new Error('cleanup mutation failed for ' + String(field));
  1167 |     }
  1168 |   }
  1169 | }
```