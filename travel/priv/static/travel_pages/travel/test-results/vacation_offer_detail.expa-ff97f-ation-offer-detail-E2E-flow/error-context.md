# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: vacation_offer_detail.expanded.spec.ts >> vacation_offer_detail >> E2E flow
- Location: vacation_offer_detail.expanded.spec.ts:1217:7

# Error details

```
Error: setup action failed for activate
```

# Test source

```ts
  755 |   const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  756 |   if (queryFields.length === 0 && mutationFields.length === 0) {
  757 |     throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  758 |   }
  759 |   ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  760 |   return ctx.__graphqlSchema;
  761 | }
  762 | 
  763 | async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  764 |   const schema = await loadGraphqlSchemaCache(ctx);
  765 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  766 |   const explicit = String(explicitField || '').trim();
  767 |   if (explicit && fields.includes(explicit)) return explicit;
  768 |   if (explicit) {
  769 |     const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
  770 |     if (camel !== explicit && fields.includes(camel)) return camel;
  771 |   }
  772 |   return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
  773 | }
  774 | 
  775 | async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  776 |   const schema = await loadGraphqlSchemaCache(ctx);
  777 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  778 |   const domainName = pascalize(domain);
  779 |   const entityName = pascalize(entity);
  780 |   const domainSnake = snakeize(domain);
  781 |   const entitySnake = snakeize(entity);
  782 |   const candidates = [];
  783 |   let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  784 |   if (mode === 'query') {
  785 |     if (actionName === 'list') {
  786 |       normalizedPrefix = 'list' + domainName + entityName;
  787 |       candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
  788 |     } else if (actionName === 'get') {
  789 |       normalizedPrefix = 'get' + domainName + entityName;
  790 |       candidates.push('get_' + domainSnake + '_' + entitySnake);
  791 |     }
  792 |   } else if (actionName === 'destroy') {
  793 |     normalizedPrefix = 'delete' + domainName + entityName;
  794 |     candidates.push('delete_' + domainSnake + '_' + entitySnake);
  795 |   } else if (actionName) {
  796 |     const actionPrefix = pascalize(actionName);
  797 |     normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
  798 |     candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  799 |   }
  800 |   candidates.push(normalizedPrefix);
  801 |   return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
  802 | }
  803 | 
  804 | function applyBindings(ctx, binds, resultValue) {
  805 |   for (const bind of Array.isArray(binds) ? binds : []) {
  806 |     const source = typeof bind?.source === 'string' ? bind.source : 'result';
  807 |     const base = source === 'result' || source === 'backend_result'
  808 |       ? resultValue
  809 |       : readContextValue(ctx, source);
  810 |     const value = readValueAtPath(base, bind?.path || null);
  811 |     assignContextValue(ctx, bind?.name, value);
  812 |   }
  813 | }
  814 | 
  815 | function refreshDataBindings(ctx) {
  816 |   applyBindings(ctx, __DATA_CONTRACT.binds, null);
  817 | }
  818 | 
  819 | function resolveTemplateDeep(ctx, value) {
  820 |   if (typeof value === 'string') return resolveTemplateString(ctx, value);
  821 |   if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  822 |   if (value && typeof value === 'object') {
  823 |     return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  824 |   }
  825 |   return value;
  826 | }
  827 | 
  828 | function toGraphqlLiteral(value) {
  829 |   if (value == null) return 'null';
  830 |   if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  831 |   if (typeof value === 'object') {
  832 |     return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  833 |   }
  834 |   if (typeof value === 'string') return JSON.stringify(value);
  835 |   if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  836 |   return JSON.stringify(String(value));
  837 | }
  838 | 
  839 | function defaultRecordId(ctx) {
  840 |   return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
  841 | }
  842 | 
  843 | function resolveBackendAssertionId(ctx, assertion) {
  844 |   const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  845 |   const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  846 |   return explicit || defaultRecordId(ctx);
  847 | }
  848 | 
  849 | async function runSetupAction(ctx, item, recordId, actionName) {
  850 |   const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  851 |   if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  852 |   const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  853 |   const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  854 |   if (Array.isArray(errors) && errors.length > 0) {
> 855 |     throw new Error('setup action failed for ' + String(actionName));
      |           ^ Error: setup action failed for activate
  856 |   }
  857 |   return payload?.data?.[field]?.result || null;
  858 | }
  859 | 
  860 | async function runSetupItem(page, ctx, item) {
  861 |   if (!item) return;
  862 |   if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
  863 |     const savedTenantId = ctx.tenant_id;
  864 |     const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
  865 |     const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
  866 |     if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
  867 |     const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
  868 |     const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
  869 |     const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
  870 |     const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
  871 |     const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
  872 |     rememberTenantContext(ctx, inputValue);
  873 |     const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
  874 |     const matched = whereField
  875 |       ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
  876 |       : rows;
  877 |     const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
  878 |     const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
  879 |     let result = matched[index] || matched[0];
  880 |     const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
  881 |     if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
  882 |       const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
  883 |       if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
  884 |       const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
  885 |       const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
  886 |       if (Array.isArray(errors) && errors.length > 0) {
  887 |         throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
  888 |       }
  889 |       result = createPayload?.data?.[createField]?.result || null;
  890 |       if (result?.id) {
  891 |         ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  892 |         ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
  893 |       }
  894 |     }
  895 |     if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
  896 |     if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
  897 |     for (const actionName of prepareActions) {
  898 |       if (!result?.id) break;
  899 |       result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
  900 |     }
  901 |     applyBindings(ctx, item.binds, result);
  902 |     refreshDataBindings(ctx);
  903 |     ctx.tenant_id = savedTenantId;
  904 |   }
  905 | }
  906 | 
  907 | async function ensureContractSetup(page, ctx) {
  908 |   if (ctx.__setupDone) return;
  909 |   for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
  910 |     await runSetupItem(page, ctx, item);
  911 |   }
  912 |   ctx.__setupDone = true;
  913 | }
  914 | 
  915 | function parseApiRef(apiRef) {
  916 |   const parts = String(apiRef || '').split('.');
  917 |   if (parts.length < 3) return null;
  918 |   return { domain: parts[0], entity: parts[1], action: parts[2] };
  919 | }
  920 | 
  921 | function collectVerificationEntries(verificationKey, caseKind, covers) {
  922 |   const entries = [];
  923 |   const pushEntry = (entry) => {
  924 |     if (!entry) return;
  925 |     if (!entries.includes(entry)) entries.push(entry);
  926 |   };
  927 |   if (verificationKey && verificationKey !== '__AUTO__') {
  928 |     pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  929 |   } else {
  930 |     if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
  931 |     for (const cover of Array.isArray(covers) ? covers : []) {
  932 |       pushEntry(__VERIFICATION_CONTRACT[cover]);
  933 |     }
  934 |   }
  935 |   for (const cover of Array.isArray(covers) ? covers : []) {
  936 |     if (!String(cover).startsWith('action_')) continue;
  937 |     const event = String(cover).slice('action_'.length);
  938 |     const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
  939 |     for (const match of matches) pushEntry(match);
  940 |   }
  941 |   return entries;
  942 | }
  943 | 
  944 | async function runWaitEntry(page, ctx, entry) {
  945 |   if (!entry) return;
  946 |   const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  947 |   await waitForLiveViewReady(page, timeout);
  948 |   const until = entry?.until || {};
  949 |   const kind = String(until?.kind || entry?.mode || '').trim();
  950 |   const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  951 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  952 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  953 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  954 |   }
  955 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
```