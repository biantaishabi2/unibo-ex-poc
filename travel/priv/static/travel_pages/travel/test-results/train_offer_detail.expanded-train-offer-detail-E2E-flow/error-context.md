# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: train_offer_detail.expanded.spec.ts >> train_offer_detail >> E2E flow
- Location: train_offer_detail.expanded.spec.ts:1234:7

# Error details

```
Error: backend get equals assertion failed: expected UPDATED_1775257572266_nlo6q8_departure_station_name got departure_station_name_003
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
            - button "deactivate" [ref=e38] [cursor=pointer]
            - button "expire" [ref=e39] [cursor=pointer]
            - button "删除" [ref=e40] [cursor=pointer]
        - generic [ref=e42]:
          - heading "基本信息" [level=3] [ref=e44]
          - generic [ref=e46]:
            - generic [ref=e48]:
              - textbox [ref=e50]
              - textbox [ref=e52]
              - textbox [ref=e54]
              - textbox [ref=e56]
              - textbox [ref=e58]
              - textbox [ref=e60]: UPDATED_1775257572266_nlo6q8_departure_station_ref_id
              - textbox [ref=e62]: UPDATED_1775257572266_nlo6q8_departure_station_name
              - textbox [ref=e64]
              - textbox [ref=e66]: UPDATED_1775257572266_nlo6q8_arrival_station_ref_id
              - textbox [ref=e68]: UPDATED_1775257572266_nlo6q8_arrival_station_name
              - textbox [ref=e70]
              - textbox [ref=e72]: 2026-02-01T09:00:00Z
              - textbox [ref=e74]: 2026-02-01T09:00:00Z
              - textbox [ref=e76]: UPDATED_1775257572266_nlo6q8_seat_class
              - textbox [ref=e78]
              - switch [disabled] [ref=e79]
              - button "waitlist_only" [disabled] [ref=e81]:
                - generic: waitlist_only
              - switch [disabled] [ref=e83]
              - textbox [ref=e85]: "200.00"
              - textbox [ref=e87]: "200.00"
              - textbox [ref=e89]: UPDATED_1775257572266_nlo6q8_currency
              - textbox [ref=e90]: UPDATED_1775257572266_nlo6q8_booking_rules_snapshot
              - textbox [ref=e91]: UPDATED_1775257572266_nlo6q8_change_rules_snapshot
              - textbox [ref=e92]: UPDATED_1775257572266_nlo6q8_refund_rules_snapshot
              - button [disabled] [ref=e94]
            - generic [ref=e96]:
              - button "取消" [disabled]
              - button "保存" [disabled]
```

# Test source

```ts
  968  |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  969  |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  970  |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  971  |   }
  972  |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
  973  |     await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  974  |   }
  975  |   if (kind === 'form_settled' && selector) {
  976  |     const formLocator = locatorFor(page, selector);
  977  |     const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
  978  |     try {
  979  |       await formLocator.waitFor({ state: 'hidden', timeout });
  980  |     } catch (error) {
  981  |       let settled = false;
  982  |       for (const candidate of fallbackSelectors) {
  983  |         try {
  984  |           await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
  985  |           settled = true;
  986  |           break;
  987  |         } catch (_candidateError) {}
  988  |       }
  989  |       const stillVisible = await formLocator.isVisible().catch(() => false);
  990  |       if (stillVisible && !settled) throw error;
  991  |     }
  992  |     await syncRouteContext(page, ctx);
  993  |   }
  994  |   if (kind === 'url_contains' || kind === 'url_and_root') {
  995  |     const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
  996  |     if (expectedUrl) {
  997  |       try {
  998  |         await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
  999  |       } catch (_e) {
  1000 |         await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
  1001 |       }
  1002 |     }
  1003 |     if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  1004 |     await syncRouteContext(page, ctx);
  1005 |   }
  1006 | }
  1007 | 
  1008 | async function retryBackendAssertion(timeout, task) {
  1009 |   const deadline = Date.now() + timeout;
  1010 |   let lastError = null;
  1011 |   while (Date.now() <= deadline) {
  1012 |     try {
  1013 |       return await task();
  1014 |     } catch (error) {
  1015 |       lastError = error;
  1016 |       await new Promise((resolve) => setTimeout(resolve, 200));
  1017 |     }
  1018 |   }
  1019 |   throw lastError || new Error('backend assertion timed out');
  1020 | }
  1021 | 
  1022 | async function snapshotPreCreateIds(ctx) {
  1023 |   if (ctx.__pre_create_ids) return;
  1024 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1025 |   if (!listApiRef) return;
  1026 |   try {
  1027 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1028 |     if (!listField) return;
  1029 |     const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
  1030 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1031 |     ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  1032 |   } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
  1033 | }
  1034 | 
  1035 | async function runCaseWait(page, ctx, waitKey, covers) {
  1036 |   const entries = [];
  1037 |   const pushEntry = (entry) => {
  1038 |     if (!entry) return;
  1039 |     if (!entries.includes(entry)) entries.push(entry);
  1040 |   };
  1041 |   if (waitKey && waitKey !== '__AUTO__') {
  1042 |     pushEntry(__WAIT_CONTRACT[waitKey]);
  1043 |   } else if (Array.isArray(covers) && covers.length === 1) {
  1044 |     pushEntry(__WAIT_CONTRACT[covers[0]]);
  1045 |   }
  1046 |   for (const entry of entries) {
  1047 |     await runWaitEntry(page, ctx, entry);
  1048 |   }
  1049 | }
  1050 | 
  1051 | async function executeBackendAssertion(ctx, assertion) {
  1052 |   if (!assertion || !assertion.api) return;
  1053 |   const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  1054 |   if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  1055 |   const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  1056 |   if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  1057 |   const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  1058 |   await retryBackendAssertion(timeout, async () => {
  1059 |     if (assertion.api === 'get') {
  1060 |       const id = resolveBackendAssertionId(ctx, assertion);
  1061 |       const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
  1062 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
  1063 |       const record = payload?.data?.[field];
  1064 |       const actual = readValueAtPath(record, assertion.path || null);
  1065 |       if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
  1066 |       if (assertion.op === 'equals' || assertion.op === 'field_equals') {
  1067 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
> 1068 |         if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
       |                                                      ^ Error: backend get equals assertion failed: expected UPDATED_1775257572266_nlo6q8_departure_station_name got departure_station_name_003
  1069 |       }
  1070 |       applyBindings(ctx, assertion.binds, record);
  1071 |       refreshDataBindings(ctx);
  1072 |       return;
  1073 |     }
  1074 |     if (assertion.api === 'list') {
  1075 |       const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
  1076 |       if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
  1077 |       const results = payload?.data?.[field]?.results || [];
  1078 |       if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
  1079 |       if (assertion.op === 'contains_equals') {
  1080 |         const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
  1081 |         const matched = Array.isArray(results)
  1082 |           ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
  1083 |           : null;
  1084 |         if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
  1085 |         applyBindings(ctx, assertion.binds, matched);
  1086 |         refreshDataBindings(ctx);
  1087 |         return;
  1088 |       }
  1089 |       if (assertion.op === 'not_contains') {
  1090 |         const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
  1091 |         const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
  1092 |         if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
  1093 |       }
  1094 |     }
  1095 |   });
  1096 | }
  1097 | 
  1098 | async function captureCreatedRecordId(ctx, caseKind, covers) {
  1099 |   const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  1100 |   if (!isCreate) return;
  1101 |   if (ctx.created_record_id) return;
  1102 |   const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  1103 |   if (!listApiRef) return;
  1104 |   try {
  1105 |     const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
  1106 |     if (!listField) return;
  1107 |     const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
  1108 |     const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
  1109 |     const allIds = rows.map((r) => r?.id).filter(Boolean);
  1110 |     if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
  1111 |     const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
  1112 |     const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
  1113 |     if (matched?.id) {
  1114 |       ctx.created_record_id = matched.id;
  1115 |       ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  1116 |       ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
  1117 |       refreshDataBindings(ctx);
  1118 |     }
  1119 |   } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
  1120 | }
  1121 | 
  1122 | async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  1123 |   const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  1124 |   for (const entry of entries) {
  1125 |     if (!entry) continue;
  1126 |     for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
  1127 |       if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
  1128 |       if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
  1129 |       if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
  1130 |     }
  1131 |     await executeBackendAssertion(ctx, entry.backend);
  1132 |   }
  1133 | }
  1134 | 
  1135 | async function runContractCleanup(ctx) {
  1136 |   const seedIds = ctx.__seed_ids || new Set();
  1137 |   const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  1138 |   for (const entry of dynamicQueue) {
  1139 |     if (!entry?.id || !entry?.domain || !entry?.entity) continue;
  1140 |     if (seedIds.has(entry.id)) continue;
  1141 |     try {
  1142 |       const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
  1143 |       if (!field) continue;
  1144 |       await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
  1145 |     } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  1146 |   }
  1147 |   for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
  1148 |     if (!item?.api) continue;
  1149 |     const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
  1150 |     if (!apiRef) continue;
  1151 |     const id = resolveCleanupSourceValue(ctx, item.source, item.path);
  1152 |     if (id == null || id === '') {
  1153 |       if (item.ignore_missing) continue;
  1154 |       throw new Error('cleanup source value missing for ' + JSON.stringify(item));
  1155 |     }
  1156 |     if (seedIds.has(id)) continue;
  1157 |     const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
  1158 |     if (!field) {
  1159 |       if (item.ignore_missing) continue;
  1160 |       throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
  1161 |     }
  1162 |     const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
  1163 |     const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  1164 |     if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
  1165 |       throw new Error('cleanup mutation failed for ' + String(field));
  1166 |     }
  1167 |   }
  1168 | }
```