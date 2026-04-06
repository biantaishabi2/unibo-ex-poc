# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_order_detail.expanded.spec.ts >> travel_order_detail >> E2E flow
- Location: travel_order_detail.expanded.spec.ts:2223:7

# Error details

```
Error: setup action failed for confirm_quote
```

# Test source

```ts
  1761 |   const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  1762 |   if (queryFields.length === 0 && mutationFields.length === 0) {
  1763 |     throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  1764 |   }
  1765 |   ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  1766 |   return ctx.__graphqlSchema;
  1767 | }
  1768 | 
  1769 | async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  1770 |   const schema = await loadGraphqlSchemaCache(ctx);
  1771 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  1772 |   const explicit = String(explicitField || '').trim();
  1773 |   if (explicit && fields.includes(explicit)) return explicit;
  1774 |   if (explicit) {
  1775 |     const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
  1776 |     if (camel !== explicit && fields.includes(camel)) return camel;
  1777 |   }
  1778 |   return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
  1779 | }
  1780 | 
  1781 | async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  1782 |   const schema = await loadGraphqlSchemaCache(ctx);
  1783 |   const fields = mode === 'query' ? schema.query : schema.mutation;
  1784 |   const domainName = pascalize(domain);
  1785 |   const entityName = pascalize(entity);
  1786 |   const domainSnake = snakeize(domain);
  1787 |   const entitySnake = snakeize(entity);
  1788 |   const candidates = [];
  1789 |   let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  1790 |   if (mode === 'query') {
  1791 |     if (actionName === 'list') {
  1792 |       normalizedPrefix = 'list' + domainName + entityName;
  1793 |       candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
  1794 |     } else if (actionName === 'get') {
  1795 |       normalizedPrefix = 'get' + domainName + entityName;
  1796 |       candidates.push('get_' + domainSnake + '_' + entitySnake);
  1797 |     }
  1798 |   } else if (actionName === 'destroy') {
  1799 |     normalizedPrefix = 'delete' + domainName + entityName;
  1800 |     candidates.push('delete_' + domainSnake + '_' + entitySnake);
  1801 |   } else if (actionName) {
  1802 |     const actionPrefix = pascalize(actionName);
  1803 |     normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
  1804 |     candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  1805 |   }
  1806 |   candidates.push(normalizedPrefix);
  1807 |   return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
  1808 | }
  1809 | 
  1810 | function applyBindings(ctx, binds, resultValue) {
  1811 |   for (const bind of Array.isArray(binds) ? binds : []) {
  1812 |     const source = typeof bind?.source === 'string' ? bind.source : 'result';
  1813 |     const base = source === 'result' || source === 'backend_result'
  1814 |       ? resultValue
  1815 |       : readContextValue(ctx, source);
  1816 |     const value = readValueAtPath(base, bind?.path || null);
  1817 |     assignContextValue(ctx, bind?.name, value);
  1818 |   }
  1819 | }
  1820 | 
  1821 | function refreshDataBindings(ctx) {
  1822 |   applyBindings(ctx, __DATA_CONTRACT.binds, null);
  1823 | }
  1824 | 
  1825 | function resolveTemplateDeep(ctx, value) {
  1826 |   if (typeof value === 'string') return resolveTemplateString(ctx, value);
  1827 |   if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  1828 |   if (value && typeof value === 'object') {
  1829 |     return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  1830 |   }
  1831 |   return value;
  1832 | }
  1833 | 
  1834 | function toGraphqlLiteral(value) {
  1835 |   if (value == null) return 'null';
  1836 |   if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  1837 |   if (typeof value === 'object') {
  1838 |     return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  1839 |   }
  1840 |   if (typeof value === 'string') return JSON.stringify(value);
  1841 |   if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  1842 |   return JSON.stringify(String(value));
  1843 | }
  1844 | 
  1845 | function defaultRecordId(ctx) {
  1846 |   return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
  1847 | }
  1848 | 
  1849 | function resolveBackendAssertionId(ctx, assertion) {
  1850 |   const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  1851 |   const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  1852 |   return explicit || defaultRecordId(ctx);
  1853 | }
  1854 | 
  1855 | async function runSetupAction(ctx, item, recordId, actionName) {
  1856 |   const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  1857 |   if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  1858 |   const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  1859 |   const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  1860 |   if (Array.isArray(errors) && errors.length > 0) {
> 1861 |     throw new Error('setup action failed for ' + String(actionName));
       |           ^ Error: setup action failed for confirm_quote
  1862 |   }
  1863 |   return payload?.data?.[field]?.result || null;
  1864 | }
  1865 | 
  1866 | async function runSetupItem(page, ctx, item) {
  1867 |   if (!item) return;
  1868 |   if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
  1869 |     const savedTenantId = ctx.tenant_id;
  1870 |     const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
  1871 |     const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
  1872 |     if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
  1873 |     const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
  1874 |     const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
  1875 |     const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
  1876 |     const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
  1877 |     const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
  1878 |     rememberTenantContext(ctx, inputValue);
  1879 |     const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
  1880 |     const matched = whereField
  1881 |       ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
  1882 |       : rows;
  1883 |     const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
  1884 |     const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
  1885 |     let result = matched[index] || matched[0];
  1886 |     const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
  1887 |     if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
  1888 |       const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
  1889 |       if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
  1890 |       const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
  1891 |       const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
  1892 |       if (Array.isArray(errors) && errors.length > 0) {
  1893 |         throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
  1894 |       }
  1895 |       result = createPayload?.data?.[createField]?.result || null;
  1896 |       if (result?.id) {
  1897 |         ctx.__cleanup_queue = ctx.__cleanup_queue || [];
  1898 |         ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
  1899 |       }
  1900 |     }
  1901 |     if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
  1902 |     if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
  1903 |     for (const actionName of prepareActions) {
  1904 |       if (!result?.id) break;
  1905 |       result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
  1906 |     }
  1907 |     applyBindings(ctx, item.binds, result);
  1908 |     refreshDataBindings(ctx);
  1909 |     ctx.tenant_id = savedTenantId;
  1910 |   }
  1911 | }
  1912 | 
  1913 | async function ensureContractSetup(page, ctx) {
  1914 |   if (ctx.__setupDone) return;
  1915 |   for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
  1916 |     await runSetupItem(page, ctx, item);
  1917 |   }
  1918 |   ctx.__setupDone = true;
  1919 | }
  1920 | 
  1921 | function parseApiRef(apiRef) {
  1922 |   const parts = String(apiRef || '').split('.');
  1923 |   if (parts.length < 3) return null;
  1924 |   return { domain: parts[0], entity: parts[1], action: parts[2] };
  1925 | }
  1926 | 
  1927 | function collectVerificationEntries(verificationKey, caseKind, covers) {
  1928 |   const entries = [];
  1929 |   const pushEntry = (entry) => {
  1930 |     if (!entry) return;
  1931 |     if (!entries.includes(entry)) entries.push(entry);
  1932 |   };
  1933 |   if (verificationKey && verificationKey !== '__AUTO__') {
  1934 |     pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  1935 |   } else {
  1936 |     if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
  1937 |     for (const cover of Array.isArray(covers) ? covers : []) {
  1938 |       pushEntry(__VERIFICATION_CONTRACT[cover]);
  1939 |     }
  1940 |   }
  1941 |   for (const cover of Array.isArray(covers) ? covers : []) {
  1942 |     if (!String(cover).startsWith('action_')) continue;
  1943 |     const event = String(cover).slice('action_'.length);
  1944 |     const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
  1945 |     for (const match of matches) pushEntry(match);
  1946 |   }
  1947 |   return entries;
  1948 | }
  1949 | 
  1950 | async function runWaitEntry(page, ctx, entry) {
  1951 |   if (!entry) return;
  1952 |   const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  1953 |   await waitForLiveViewReady(page, timeout);
  1954 |   const until = entry?.until || {};
  1955 |   const kind = String(until?.kind || entry?.mode || '').trim();
  1956 |   const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  1957 |   const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  1958 |   if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
  1959 |     await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  1960 |   }
  1961 |   if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
```