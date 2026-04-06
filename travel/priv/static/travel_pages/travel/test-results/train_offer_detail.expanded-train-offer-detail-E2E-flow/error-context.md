# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: train_offer_detail.expanded.spec.ts >> train_offer_detail >> E2E flow
- Location: train_offer_detail.expanded.spec.ts:1235:7

# Error details

```
Error: setup action failed for activate
```

# Test source

```ts
  773 |   const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  774 |   if (queryFields.length === 0 && mutationFields.length === 0) {
  775 |     throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  776 |   }
  777 |   ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  778 |   return ctx.__graphqlSchema;
  779 | }
  780 | 
  781 | async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  782 |   const schema = await loadGraphqlSchemaCache(ctx);
  783 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  784 |   const explicit = String(explicitField || '').trim();
  785 |   if (explicit && fields.includes(explicit)) return explicit;
  786 |   if (explicit) {
  787 |     const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
  788 |     if (camel !== explicit && fields.includes(camel)) return camel;
  789 |   }
  790 |   return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
  791 | }
  792 | 
  793 | async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  794 |   const schema = await loadGraphqlSchemaCache(ctx);
  795 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  796 |   const domainName = pascalize(domain);
  797 |   const entityName = pascalize(entity);
  798 |   const domainSnake = snakeize(domain);
  799 |   const entitySnake = snakeize(entity);
  800 |   const candidates = [];
  801 |   let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  802 |   if (mode === 'query') {
  803 |     if (actionName === 'list') {
  804 |       normalizedPrefix = 'list' + domainName + entityName;
  805 |       candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
  806 |     } else if (actionName === 'get') {
  807 |       normalizedPrefix = 'get' + domainName + entityName;
  808 |       candidates.push('get_' + domainSnake + '_' + entitySnake);
  809 |     }
  810 |   } else if (actionName === 'destroy') {
  811 |     normalizedPrefix = 'delete' + domainName + entityName;
  812 |     candidates.push('delete_' + domainSnake + '_' + entitySnake);
  813 |   } else if (actionName) {
  814 |     const actionPrefix = pascalize(actionName);
  815 |     normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
  816 |     candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  817 |   }
  818 |   candidates.push(normalizedPrefix);
  819 |   return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
  820 | }
  821 | 
  822 | function applyBindings(ctx, binds, resultValue) {
  823 |   for (const bind of Array.isArray(binds) ? binds : []) {
  824 |     const source = typeof bind?.source === 'string' ? bind.source : 'result';
  825 |     const base = source === 'result' || source === 'backend_result'
  826 |       ? resultValue
  827 |       : readContextValue(ctx, source);
  828 |     const value = readValueAtPath(base, bind?.path || null);
  829 |     assignContextValue(ctx, bind?.name, value);
  830 |   }
  831 | }
  832 | 
  833 | function refreshDataBindings(ctx) {
  834 |   applyBindings(ctx, __DATA_CONTRACT.binds, null);
  835 | }
  836 | 
  837 | function resolveTemplateDeep(ctx, value) {
  838 |   if (typeof value === 'string') return resolveTemplateString(ctx, value);
  839 |   if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  840 |   if (value && typeof value === 'object') {
  841 |     return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  842 |   }
  843 |   return value;
  844 | }
  845 | 
  846 | function toGraphqlLiteral(value) {
  847 |   if (value == null) return 'null';
  848 |   if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  849 |   if (typeof value === 'object') {
  850 |     return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  851 |   }
  852 |   if (typeof value === 'string') return JSON.stringify(value);
  853 |   if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  854 |   return JSON.stringify(String(value));
  855 | }
  856 | 
  857 | function defaultRecordId(ctx) {
  858 |   return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
  859 | }
  860 | 
  861 | function resolveBackendAssertionId(ctx, assertion) {
  862 |   const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  863 |   const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  864 |   return explicit || defaultRecordId(ctx);
  865 | }
  866 | 
  867 | async function runSetupAction(ctx, item, recordId, actionName) {
  868 |   const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  869 |   if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  870 |   const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  871 |   const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  872 |   if (Array.isArray(errors) && errors.length > 0) {
> 873 |     throw new Error('setup action failed for ' + String(actionName));
      |           ^ Error: setup action failed for activate
  874 |   }
  875 |   return payload?.data?.[field]?.result || null;
  876 | }
  877 | 
  878 | async function runSetupItem(page, ctx, item) {
  879 |   if (!item) return;
  880 |   if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
  881 |     const savedTenantId = ctx.tenant_id;
  882 |     const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
  883 |     const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
  884 |     if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
  885 |     const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
  886 |     const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
  887 |     const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
  888 |     const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
  889 |     const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
  890 |     rememberTenantContext(ctx, inputValue);
  891 |     const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
  892 |     const matched = whereField
  893 |       ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
  894 |       : rows;
  895 |     const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
  896 |     const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
  897 |     let result = matched[index] || matched[0];
  898 |     const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
  899 |     if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
  900 |       const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
  901 |       if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
  902 |       const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
  903 |       const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
  904 |       if (Array.isArray(errors) && errors.length > 0) {
  905 |         throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
  906 |       }
  907 |       result = createPayload?.data?.[createField]?.result || null;
  908 |       if (result?.id) {
  909 |         ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  910 |         ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
  911 |       }
  912 |     }
  913 |     if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
  914 |     if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
  915 |     for (const actionName of prepareActions) {
  916 |       if (!result?.id) break;
  917 |       result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
  918 |     }
  919 |     applyBindings(ctx, item.binds, result);
  920 |     refreshDataBindings(ctx);
  921 |     ctx.tenant_id = savedTenantId;
  922 |   }
  923 | }
  924 | 
  925 | async function ensureContractSetup(page, ctx) {
  926 |   if (ctx.__setupDone) return;
  927 |   for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
  928 |     await runSetupItem(page, ctx, item);
  929 |   }
  930 |   ctx.__setupDone = true;
  931 | }
  932 | 
  933 | function parseApiRef(apiRef) {
  934 |   const parts = String(apiRef || '').split('.');
  935 |   if (parts.length < 3) return null;
  936 |   return { domain: parts[0], entity: parts[1], action: parts[2] };
  937 | }
  938 | 
  939 | function collectVerificationEntries(verificationKey, caseKind, covers) {
  940 |   const entries = [];
  941 |   const pushEntry = (entry) => {
  942 |     if (!entry) return;
  943 |     if (!entries.includes(entry)) entries.push(entry);
  944 |   };
  945 |   if (verificationKey && verificationKey !== '__AUTO__') {
  946 |     pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  947 |   } else {
  948 |     if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
  949 |     for (const cover of Array.isArray(covers) ? covers : []) {
  950 |       pushEntry(__VERIFICATION_CONTRACT[cover]);
  951 |     }
  952 |   }
  953 |   for (const cover of Array.isArray(covers) ? covers : []) {
  954 |     if (!String(cover).startsWith('action_')) continue;
  955 |     const event = String(cover).slice('action_'.length);
  956 |     const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
  957 |     for (const match of matches) pushEntry(match);
  958 |   }
  959 |   return entries;
  960 | }
  961 | 
  962 | async function runWaitEntry(page, ctx, entry) {
  963 |   if (!entry) return;
  964 |   const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  965 |   await waitForLiveViewReady(page, timeout);
  966 |   const until = entry?.until || {};
  967 |   const kind = String(until?.kind || entry?.mode || '').trim();
  968 |   const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  969 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  970 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  971 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  972 |   }
  973 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
```