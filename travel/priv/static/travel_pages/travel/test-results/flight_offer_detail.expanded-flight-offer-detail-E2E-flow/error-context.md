# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: flight_offer_detail.expanded.spec.ts >> flight_offer_detail >> E2E flow
- Location: flight_offer_detail.expanded.spec.ts:1220:7

# Error details

```
Error: setup action failed for activate
```

# Test source

```ts
  758 |   const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  759 |   if (queryFields.length === 0 && mutationFields.length === 0) {
  760 |     throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  761 |   }
  762 |   ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  763 |   return ctx.__graphqlSchema;
  764 | }
  765 | 
  766 | async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  767 |   const schema = await loadGraphqlSchemaCache(ctx);
  768 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  769 |   const explicit = String(explicitField || '').trim();
  770 |   if (explicit && fields.includes(explicit)) return explicit;
  771 |   if (explicit) {
  772 |     const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
  773 |     if (camel !== explicit && fields.includes(camel)) return camel;
  774 |   }
  775 |   return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
  776 | }
  777 | 
  778 | async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  779 |   const schema = await loadGraphqlSchemaCache(ctx);
  780 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  781 |   const domainName = pascalize(domain);
  782 |   const entityName = pascalize(entity);
  783 |   const domainSnake = snakeize(domain);
  784 |   const entitySnake = snakeize(entity);
  785 |   const candidates = [];
  786 |   let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  787 |   if (mode === 'query') {
  788 |     if (actionName === 'list') {
  789 |       normalizedPrefix = 'list' + domainName + entityName;
  790 |       candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
  791 |     } else if (actionName === 'get') {
  792 |       normalizedPrefix = 'get' + domainName + entityName;
  793 |       candidates.push('get_' + domainSnake + '_' + entitySnake);
  794 |     }
  795 |   } else if (actionName === 'destroy') {
  796 |     normalizedPrefix = 'delete' + domainName + entityName;
  797 |     candidates.push('delete_' + domainSnake + '_' + entitySnake);
  798 |   } else if (actionName) {
  799 |     const actionPrefix = pascalize(actionName);
  800 |     normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
  801 |     candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  802 |   }
  803 |   candidates.push(normalizedPrefix);
  804 |   return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
  805 | }
  806 | 
  807 | function applyBindings(ctx, binds, resultValue) {
  808 |   for (const bind of Array.isArray(binds) ? binds : []) {
  809 |     const source = typeof bind?.source === 'string' ? bind.source : 'result';
  810 |     const base = source === 'result' || source === 'backend_result'
  811 |       ? resultValue
  812 |       : readContextValue(ctx, source);
  813 |     const value = readValueAtPath(base, bind?.path || null);
  814 |     assignContextValue(ctx, bind?.name, value);
  815 |   }
  816 | }
  817 | 
  818 | function refreshDataBindings(ctx) {
  819 |   applyBindings(ctx, __DATA_CONTRACT.binds, null);
  820 | }
  821 | 
  822 | function resolveTemplateDeep(ctx, value) {
  823 |   if (typeof value === 'string') return resolveTemplateString(ctx, value);
  824 |   if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  825 |   if (value && typeof value === 'object') {
  826 |     return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  827 |   }
  828 |   return value;
  829 | }
  830 | 
  831 | function toGraphqlLiteral(value) {
  832 |   if (value == null) return 'null';
  833 |   if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  834 |   if (typeof value === 'object') {
  835 |     return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  836 |   }
  837 |   if (typeof value === 'string') return JSON.stringify(value);
  838 |   if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  839 |   return JSON.stringify(String(value));
  840 | }
  841 | 
  842 | function defaultRecordId(ctx) {
  843 |   return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
  844 | }
  845 | 
  846 | function resolveBackendAssertionId(ctx, assertion) {
  847 |   const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  848 |   const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  849 |   return explicit || defaultRecordId(ctx);
  850 | }
  851 | 
  852 | async function runSetupAction(ctx, item, recordId, actionName) {
  853 |   const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  854 |   if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  855 |   const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  856 |   const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  857 |   if (Array.isArray(errors) && errors.length > 0) {
> 858 |     throw new Error('setup action failed for ' + String(actionName));
      |           ^ Error: setup action failed for activate
  859 |   }
  860 |   return payload?.data?.[field]?.result || null;
  861 | }
  862 | 
  863 | async function runSetupItem(page, ctx, item) {
  864 |   if (!item) return;
  865 |   if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
  866 |     const savedTenantId = ctx.tenant_id;
  867 |     const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
  868 |     const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
  869 |     if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
  870 |     const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
  871 |     const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
  872 |     const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
  873 |     const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
  874 |     const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
  875 |     rememberTenantContext(ctx, inputValue);
  876 |     const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
  877 |     const matched = whereField
  878 |       ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
  879 |       : rows;
  880 |     const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
  881 |     const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
  882 |     let result = matched[index] || matched[0];
  883 |     const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
  884 |     if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
  885 |       const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
  886 |       if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
  887 |       const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
  888 |       const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
  889 |       if (Array.isArray(errors) && errors.length > 0) {
  890 |         throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
  891 |       }
  892 |       result = createPayload?.data?.[createField]?.result || null;
  893 |       if (result?.id) {
  894 |         ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  895 |         ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
  896 |       }
  897 |     }
  898 |     if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
  899 |     if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
  900 |     for (const actionName of prepareActions) {
  901 |       if (!result?.id) break;
  902 |       result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
  903 |     }
  904 |     applyBindings(ctx, item.binds, result);
  905 |     refreshDataBindings(ctx);
  906 |     ctx.tenant_id = savedTenantId;
  907 |   }
  908 | }
  909 | 
  910 | async function ensureContractSetup(page, ctx) {
  911 |   if (ctx.__setupDone) return;
  912 |   for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
  913 |     await runSetupItem(page, ctx, item);
  914 |   }
  915 |   ctx.__setupDone = true;
  916 | }
  917 | 
  918 | function parseApiRef(apiRef) {
  919 |   const parts = String(apiRef || '').split('.');
  920 |   if (parts.length < 3) return null;
  921 |   return { domain: parts[0], entity: parts[1], action: parts[2] };
  922 | }
  923 | 
  924 | function collectVerificationEntries(verificationKey, caseKind, covers) {
  925 |   const entries = [];
  926 |   const pushEntry = (entry) => {
  927 |     if (!entry) return;
  928 |     if (!entries.includes(entry)) entries.push(entry);
  929 |   };
  930 |   if (verificationKey && verificationKey !== '__AUTO__') {
  931 |     pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  932 |   } else {
  933 |     if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
  934 |     for (const cover of Array.isArray(covers) ? covers : []) {
  935 |       pushEntry(__VERIFICATION_CONTRACT[cover]);
  936 |     }
  937 |   }
  938 |   for (const cover of Array.isArray(covers) ? covers : []) {
  939 |     if (!String(cover).startsWith('action_')) continue;
  940 |     const event = String(cover).slice('action_'.length);
  941 |     const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
  942 |     for (const match of matches) pushEntry(match);
  943 |   }
  944 |   return entries;
  945 | }
  946 | 
  947 | async function runWaitEntry(page, ctx, entry) {
  948 |   if (!entry) return;
  949 |   const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  950 |   await waitForLiveViewReady(page, timeout);
  951 |   const until = entry?.until || {};
  952 |   const kind = String(until?.kind || entry?.mode || '').trim();
  953 |   const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  954 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  955 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  956 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  957 |   }
  958 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
```