import { test, expect } from '@playwright/test';

const __DATA_CONTRACT = {
  "binds": [
    {
      "name": "route_record_id",
      "path": "id",
      "source": "route"
    },
    {
      "name": "created_display_value",
      "path": "supplier_code",
      "source": "form"
    }
  ],
  "cleanup": [
    {
      "api": "destroy",
      "ignore_missing": true,
      "path": "id",
      "source": "created_record_id"
    }
  ],
  "inputs": [
    "route",
    "form",
    "generated_form_values"
  ],
  "setup": [
    {
      "binds": [
        {
          "name": "seed_record_id",
          "path": "id",
          "source": "result"
        },
        {
          "name": "active_record_id",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "never",
      "create_blockers": [
        "actor_required"
      ],
      "depends_on": [],
      "domain": "Travel",
      "entity": "FlightOffer",
      "freshness": "match_only",
      "graphql_field": "listTravelFlightOffers",
      "index": 0,
      "kind": "entity_list_first",
      "name": "resolve_current_record",
      "owner": "root",
      "where_equals": "draft",
      "where_path": "sale_status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_activate",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelFlightOffer",
      "create_input": {
        "arrival_airport_code": "E2E_{{__run_id}}_arrival_airport_code_state_activate_0",
        "arrival_at": "2026-01-01T09:00:00Z",
        "baggage_policy": "E2E_{{__run_id}}_baggage_policy_state_activate_0",
        "cabin_class": "E2E_{{__run_id}}_cabin_class_state_activate_0",
        "currency": "E2E_{{__run_id}}_currency_state_activate_0",
        "departure_airport_code": "E2E_{{__run_id}}_departure_airport_code_state_activate_0",
        "departure_at": "2026-01-01T09:00:00Z",
        "fare_family": "E2E_{{__run_id}}_fare_family_state_activate_0",
        "flight_no": "E2E_{{__run_id}}_flight_no_state_activate_0",
        "host_shop_id": "364028f0-e7d9-40dc-94d2-d5c2e7d1e5d1",
        "itinerary_code": "E2E_{{__run_id}}_itinerary_code_state_activate_0",
        "listed_price": 1,
        "refund_change_policy": "E2E_{{__run_id}}_refund_change_policy_state_activate_0",
        "sale_status": "draft",
        "seats_available": 1,
        "settlement_price": 1,
        "supplier_code": "E2E_{{__run_id}}_supplier_code_state_activate_0",
        "tenant_id": "f2e5d9c2-e8ca-4ed5-88e2-cae4d5d3cec3"
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "FlightOffer",
      "freshness": "prefer_create",
      "graphql_field": "listTravelFlightOffers",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "name": "resolve_state_action_record_activate",
      "owner": "root",
      "prepare_actions": [],
      "where_equals": "draft",
      "where_path": "sale_status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_deactivate",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelFlightOffer",
      "create_input": {
        "arrival_airport_code": "E2E_{{__run_id}}_arrival_airport_code_state_deactivate_0",
        "arrival_at": "2026-01-01T09:00:00Z",
        "baggage_policy": "E2E_{{__run_id}}_baggage_policy_state_deactivate_0",
        "cabin_class": "E2E_{{__run_id}}_cabin_class_state_deactivate_0",
        "currency": "E2E_{{__run_id}}_currency_state_deactivate_0",
        "departure_airport_code": "E2E_{{__run_id}}_departure_airport_code_state_deactivate_0",
        "departure_at": "2026-01-01T09:00:00Z",
        "fare_family": "E2E_{{__run_id}}_fare_family_state_deactivate_0",
        "flight_no": "E2E_{{__run_id}}_flight_no_state_deactivate_0",
        "host_shop_id": "383c3d25-4609-40dc-94d2-d8c4d4cbe3d9",
        "itinerary_code": "E2E_{{__run_id}}_itinerary_code_state_deactivate_0",
        "listed_price": 1,
        "refund_change_policy": "E2E_{{__run_id}}_refund_change_policy_state_deactivate_0",
        "sale_status": "draft",
        "seats_available": 1,
        "settlement_price": 1,
        "supplier_code": "E2E_{{__run_id}}_supplier_code_state_deactivate_0",
        "tenant_id": "274409c2-e8ca-4ed8-8acf-c4e2ddd5cad8"
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "FlightOffer",
      "freshness": "prefer_create",
      "graphql_field": "listTravelFlightOffers",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "name": "resolve_state_action_record_deactivate",
      "owner": "root",
      "prepare_actions": [
        "activate"
      ],
      "where_equals": "draft",
      "where_path": "sale_status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_expire",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelFlightOffer",
      "create_input": {
        "arrival_airport_code": "E2E_{{__run_id}}_arrival_airport_code_state_expire_1",
        "arrival_at": "2026-01-01T09:00:00Z",
        "baggage_policy": "E2E_{{__run_id}}_baggage_policy_state_expire_1",
        "cabin_class": "E2E_{{__run_id}}_cabin_class_state_expire_1",
        "currency": "E2E_{{__run_id}}_currency_state_expire_1",
        "departure_airport_code": "E2E_{{__run_id}}_departure_airport_code_state_expire_1",
        "departure_at": "2026-01-01T09:00:00Z",
        "fare_family": "E2E_{{__run_id}}_fare_family_state_expire_1",
        "flight_no": "E2E_{{__run_id}}_flight_no_state_expire_1",
        "host_shop_id": "210cc9c0-e7d9-40dc-94d2-d9d7e3d1e1d5",
        "itinerary_code": "E2E_{{__run_id}}_itinerary_code_state_expire_1",
        "listed_price": 1,
        "refund_change_policy": "E2E_{{__run_id}}_refund_change_policy_state_expire_1",
        "sale_status": "draft",
        "seats_available": 1,
        "settlement_price": 1,
        "supplier_code": "E2E_{{__run_id}}_supplier_code_state_expire_1",
        "tenant_id": "c2e5d9c2-e8ca-4ed9-9dde-cae0d9be9a64"
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "FlightOffer",
      "freshness": "prefer_create",
      "graphql_field": "listTravelFlightOffers",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "name": "resolve_state_action_record_expire",
      "owner": "root",
      "prepare_actions": [
        "activate"
      ],
      "where_equals": "draft",
      "where_path": "sale_status"
    }
  ]
};
const __WAIT_CONTRACT = {
  "action": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_activate": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_deactivate": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_expire": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "destroy": {
    "mode": "url_and_root",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_list"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "url_contains",
      "selector": "#flight_offer_list",
      "state_key": null,
      "url_contains": "/pages/travel/flight_offer"
    },
    "url_contains": "/pages/travel/flight_offer"
  },
  "form_submit": {
    "mode": "form_settled",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#flight_offer_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "form_settled",
      "selector": "#flight_offer_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "load": {
    "mode": "dom_visible",
    "reload_messages": [],
    "selectors": [
      "#flight_offer_detail"
    ],
    "state_keys": [],
    "timeout": 5000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "toggle_edit": {
    "mode": "dom_visible",
    "reload_messages": [],
    "selectors": [
      "#flight_offer_edit_form, #main_form, form[phx-submit=\"form_submit\"]"
    ],
    "state_keys": [],
    "timeout": 3000,
    "until": {
      "kind": "visible",
      "selector": "#flight_offer_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  }
};
const __VERIFICATION_CONTRACT = {
  "action_activate": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "active",
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "equals",
      "path": "sale_status",
      "source": "active_record_id"
    },
    "event": "activate",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#flight_offer_status_badge, #flight_offer_fcl_status_badge, #state_badge",
        "value": "active"
      }
    ]
  },
  "action_deactivate": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "inactive",
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "equals",
      "path": "sale_status",
      "source": "active_record_id"
    },
    "event": "deactivate",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#flight_offer_status_badge, #flight_offer_fcl_status_badge, #state_badge",
        "value": "inactive"
      }
    ]
  },
  "action_expire": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "expired",
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "equals",
      "path": "sale_status",
      "source": "active_record_id"
    },
    "event": "expire",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#flight_offer_status_badge, #flight_offer_fcl_status_badge, #state_badge",
        "value": "expired"
      }
    ]
  },
  "create": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "created_record_id"
        }
      ],
      "binds": [
        {
          "name": "active_record_id",
          "path": "id",
          "source": "backend_result"
        },
        {
          "name": "created_record_id",
          "path": "id",
          "source": "backend_result"
        }
      ],
      "equals": "$form.supplier_code",
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "field_equals",
      "path": "supplier_code",
      "source": "created_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#flight_offer_detail",
        "value": null
      }
    ]
  },
  "destroy": {
    "backend": {
      "api": "list",
      "args": [],
      "binds": [],
      "equals": null,
      "excludes_source": "active_record_id",
      "graphql_field": "listTravelFlightOffers",
      "op": "not_contains",
      "path": "results[].id",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "url_contains",
        "selector": null,
        "value": "/pages/travel/flight_offer"
      },
      {
        "assert": "visible",
        "selector": "#flight_offer_list",
        "value": null
      }
    ]
  },
  "load": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [
        {
          "name": "active_record_id",
          "path": "id",
          "source": "backend_result"
        }
      ],
      "equals": null,
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "exists",
      "path": "id",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#flight_offer_detail",
        "value": null
      }
    ]
  },
  "state_transitions": [
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "active",
        "excludes_source": null,
        "graphql_field": "getTravelFlightOffer",
        "op": "equals",
        "path": "sale_status",
        "source": "active_record_id"
      },
      "event": "activate",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#flight_offer_status_badge, #flight_offer_fcl_status_badge, #state_badge",
          "value": "active"
        }
      ]
    },
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "inactive",
        "excludes_source": null,
        "graphql_field": "getTravelFlightOffer",
        "op": "equals",
        "path": "sale_status",
        "source": "active_record_id"
      },
      "event": "deactivate",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#flight_offer_status_badge, #flight_offer_fcl_status_badge, #state_badge",
          "value": "inactive"
        }
      ]
    }
  ],
  "toggle_edit": {
    "backend": null,
    "ui": [
      {
        "assert": "visible",
        "selector": "#flight_offer_detail",
        "value": null
      }
    ]
  },
  "update": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "$form.arrival_airport_ref_id",
      "excludes_source": null,
      "graphql_field": "getTravelFlightOffer",
      "op": "equals",
      "path": "arrival_airport_ref_id",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#flight_offer_detail",
        "value": null
      }
    ]
  }
};
const __BACKEND_API_MAP = {
  "list": "Travel.FlightOffer.list",
  "get": "Travel.FlightOffer.get",
  "create": "Travel.FlightOffer.create",
  "update": "Travel.FlightOffer.update",
  "destroy": "Travel.FlightOffer.destroy"
};
const __BACKEND_SELECTION = "id tenant_id: tenantId host_shop_id: hostShopId supplier_code: supplierCode itinerary_code: itineraryCode flight_no: flightNo departure_airport_code: departureAirportCode arrival_airport_code: arrivalAirportCode departure_at: departureAt arrival_at: arrivalAt cabin_class: cabinClass fare_family: fareFamily listed_price: listedPrice settlement_price: settlementPrice currency seats_available: seatsAvailable baggage_policy: baggagePolicy refund_change_policy: refundChangePolicy sale_status: saleStatus inserted_at: insertedAt updated_at: updatedAt";
const __BASE_URL = "http://localhost:4100/";
const __GRAPHQL_URL = new URL("/api/graphql", __BASE_URL).toString();

function locatorFor(page, selector) {
  const loc = page.locator(selector);
  return selector.includes(',') ? loc.first() : loc;
}

function readValueAtPath(value, path) {
  if (!path) return value;
  return String(path).split('.').reduce((acc, part) => {
    if (acc == null) return undefined;
    if (part === '[]') return Array.isArray(acc) ? acc : undefined;
    if (/^\d+$/.test(part)) return Array.isArray(acc) ? acc[Number(part)] : undefined;
    if (part.endsWith('[]')) {
      const key = part.slice(0, -2);
      const next = acc?.[key];
      return Array.isArray(next) ? next : undefined;
    }
    return acc?.[part];
  }, value);
}

function readContextValue(ctx, source) {
  if (!source) return undefined;
  const parts = String(source).split('.');
  const root = parts.shift();
  const base = root && Object.prototype.hasOwnProperty.call(ctx, root) ? ctx[root] : ctx?.[source];
  if (parts.length === 0) return base;
  return readValueAtPath(base, parts.join('.'));
}

function resolveCleanupSourceValue(ctx, source, path) {
  const base = readContextValue(ctx, source);
  if (base == null) return undefined;
  if (!path || typeof base !== 'object') return base;
  const nested = readValueAtPath(base, path);
  return nested == null ? base : nested;
}

function assignContextValue(ctx, name, value) {
  if (!name) return;
  const parts = String(name).split('.').filter(Boolean);
  if (parts.length === 0) return;
  let cursor = ctx;
  while (parts.length > 1) {
    const key = parts.shift();
    if (!key) return;
    const next = cursor[key];
    if (!next || typeof next !== 'object') cursor[key] = {};
    cursor = cursor[key];
  }
  cursor[parts[0]] = value;
}

function resolveStateActionTemplateValue(ctx, key) {
  const name = String(key || '').trim();
  if (!name.startsWith('state_action_record_id_')) return undefined;
  return defaultRecordId(ctx);
}

function resolveTemplateString(ctx, raw) {
  if (typeof raw !== 'string' || raw === '') return raw;
  let out = raw.replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_m, key) => {
    const normalizedKey = key.trim();
    const v = readContextValue(ctx, normalizedKey);
    if (v != null) return String(v);
    const fallback = resolveStateActionTemplateValue(ctx, normalizedKey);
    return fallback == null ? '' : String(fallback);
  });
  out = out.replace(/\$([a-zA-Z0-9_.]+)/g, (_m, key) => {
    const v = readContextValue(ctx, key);
    return v == null ? '' : String(v);
  });
  return out;
}

function escapeRegex(value) {
  return String(value || '').replace(/[.*+?^$()|[\]\\]/g, '\\$&');
}

function pascalize(value) {
  return String(value || '')
    .split(/[^a-zA-Z0-9]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

function snakeize(value) {
  return String(value || '')
    .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .toLowerCase();
}

function pluralize(value) {
  const s = String(value || '');
  return s + 's';
}

function tenantIdFromValue(value) {
  if (typeof value === 'string' || typeof value === 'number') {
    return String(value || '').trim();
  }
  if (value && typeof value === 'object') {
    const direct = value.tenant_id ?? value.tenantId;
    return direct == null ? '' : String(direct).trim();
  }
  return '';
}

function rememberTenantContext(ctx, value) {
  const tenantId = tenantIdFromValue(value);
  if (tenantId) ctx.tenant_id = tenantId;
}

function graphqlHeaders(ctx, extraHeaders) {
  const headers = { 'content-type': 'application/json', ...(extraHeaders || {}) };
  const tenantId = tenantIdFromValue(ctx?.tenant_id) || tenantIdFromValue(ctx?.tenant);
  if (tenantId && !headers['x-tenant-id'] && !headers['X-Tenant-Id']) {
    headers['x-tenant-id'] = tenantId;
  }
  return headers;
}

async function graphqlRequest(ctx, query, variables, extraHeaders) {
  let response;
  try {
    response = await fetch(__GRAPHQL_URL, {
      method: 'POST',
      headers: graphqlHeaders(ctx, extraHeaders),
      body: JSON.stringify({ query, variables }),
    });
  } catch (e) {
    throw new Error('GraphQL request to ' + __GRAPHQL_URL + ' failed: ' + e.message);
  }
  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error('GraphQL ' + __GRAPHQL_URL + ' returned ' + response.status + ': ' + text.slice(0, 200));
  }
  return await response.json();
}

async function loadGraphqlSchemaCache(ctx) {
  if (ctx.__graphqlSchema) return ctx.__graphqlSchema;
  const payload = await graphqlRequest(ctx, '{ __schema { queryType { fields { name } } mutationType { fields { name } } } }', {});
  const queryFields = (payload?.data?.__schema?.queryType?.fields || []).map((field) => field.name);
  const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  if (queryFields.length === 0 && mutationFields.length === 0) {
    throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  }
  ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  return ctx.__graphqlSchema;
}

async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  const schema = await loadGraphqlSchemaCache(ctx);
  const fields = mode === 'query' ? schema.query : schema.mutation;
  const explicit = String(explicitField || '').trim();
  if (explicit && fields.includes(explicit)) return explicit;
  if (explicit) {
    const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
    if (camel !== explicit && fields.includes(camel)) return camel;
  }
  return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
}

async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  const schema = await loadGraphqlSchemaCache(ctx);
  const fields = mode === 'query' ? schema.query : schema.mutation;
  const domainName = pascalize(domain);
  const entityName = pascalize(entity);
  const domainSnake = snakeize(domain);
  const entitySnake = snakeize(entity);
  const candidates = [];
  let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  if (mode === 'query') {
    if (actionName === 'list') {
      normalizedPrefix = 'list' + domainName + entityName;
      candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
    } else if (actionName === 'get') {
      normalizedPrefix = 'get' + domainName + entityName;
      candidates.push('get_' + domainSnake + '_' + entitySnake);
    }
  } else if (actionName === 'destroy') {
    normalizedPrefix = 'delete' + domainName + entityName;
    candidates.push('delete_' + domainSnake + '_' + entitySnake);
  } else if (actionName) {
    const actionPrefix = pascalize(actionName);
    normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
    candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  }
  candidates.push(normalizedPrefix);
  return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
}

function applyBindings(ctx, binds, resultValue) {
  for (const bind of Array.isArray(binds) ? binds : []) {
    const source = typeof bind?.source === 'string' ? bind.source : 'result';
    const base = source === 'result' || source === 'backend_result'
      ? resultValue
      : readContextValue(ctx, source);
    const value = readValueAtPath(base, bind?.path || null);
    assignContextValue(ctx, bind?.name, value);
  }
}

function refreshDataBindings(ctx) {
  applyBindings(ctx, __DATA_CONTRACT.binds, null);
}

function resolveTemplateDeep(ctx, value) {
  if (typeof value === 'string') return resolveTemplateString(ctx, value);
  if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  }
  return value;
}

function toGraphqlLiteral(value) {
  if (value == null) return 'null';
  if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  if (typeof value === 'object') {
    return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  }
  if (typeof value === 'string') return JSON.stringify(value);
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  return JSON.stringify(String(value));
}

function defaultRecordId(ctx) {
  return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
}

function resolveBackendAssertionId(ctx, assertion) {
  const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  return explicit || defaultRecordId(ctx);
}

async function runSetupAction(ctx, item, recordId, actionName) {
  const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  if (Array.isArray(errors) && errors.length > 0) {
    throw new Error('setup action failed for ' + String(actionName));
  }
  return payload?.data?.[field]?.result || null;
}

async function runSetupItem(page, ctx, item) {
  if (!item) return;
  if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
    const savedTenantId = ctx.tenant_id;
    const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
    const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
    if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
    const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
    const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
    const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
    const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
    const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
    rememberTenantContext(ctx, inputValue);
    const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
    const matched = whereField
      ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
      : rows;
    const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
    const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
    let result = matched[index] || matched[0];
    const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
    if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
      const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
      if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
      const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
      const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
      if (Array.isArray(errors) && errors.length > 0) {
        throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
      }
      result = createPayload?.data?.[createField]?.result || null;
      if (result?.id) {
        ctx.__cleanup_queue = ctx.__cleanup_queue || [];
        ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
      }
    }
    if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
    if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
    for (const actionName of prepareActions) {
      if (!result?.id) break;
      result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
    }
    applyBindings(ctx, item.binds, result);
    refreshDataBindings(ctx);
    ctx.tenant_id = savedTenantId;
  }
}

async function ensureContractSetup(page, ctx) {
  if (ctx.__setupDone) return;
  for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
    await runSetupItem(page, ctx, item);
  }
  ctx.__setupDone = true;
}

function parseApiRef(apiRef) {
  const parts = String(apiRef || '').split('.');
  if (parts.length < 3) return null;
  return { domain: parts[0], entity: parts[1], action: parts[2] };
}

function collectVerificationEntries(verificationKey, caseKind, covers) {
  const entries = [];
  const pushEntry = (entry) => {
    if (!entry) return;
    if (!entries.includes(entry)) entries.push(entry);
  };
  if (verificationKey && verificationKey !== '__AUTO__') {
    pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  } else {
    if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
    for (const cover of Array.isArray(covers) ? covers : []) {
      pushEntry(__VERIFICATION_CONTRACT[cover]);
    }
  }
  for (const cover of Array.isArray(covers) ? covers : []) {
    if (!String(cover).startsWith('action_')) continue;
    const event = String(cover).slice('action_'.length);
    const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
    for (const match of matches) pushEntry(match);
  }
  return entries;
}

async function runWaitEntry(page, ctx, entry) {
  if (!entry) return;
  const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  await waitForLiveViewReady(page, timeout);
  const until = entry?.until || {};
  const kind = String(until?.kind || entry?.mode || '').trim();
  const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
    await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  }
  if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
    await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  }
  if (kind === 'form_settled' && selector) {
    const formLocator = locatorFor(page, selector);
    const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
    try {
      await formLocator.waitFor({ state: 'hidden', timeout });
    } catch (error) {
      let settled = false;
      for (const candidate of fallbackSelectors) {
        try {
          await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
          settled = true;
          break;
        } catch (_candidateError) {}
      }
      const stillVisible = await formLocator.isVisible().catch(() => false);
      if (stillVisible && !settled) throw error;
    }
    await syncRouteContext(page, ctx);
  }
  if (kind === 'url_contains' || kind === 'url_and_root') {
    const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
    if (expectedUrl) {
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
      } catch (_e) {
        await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
      }
    }
    if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
    await syncRouteContext(page, ctx);
  }
}

async function retryBackendAssertion(timeout, task) {
  const deadline = Date.now() + timeout;
  let lastError = null;
  while (Date.now() <= deadline) {
    try {
      return await task();
    } catch (error) {
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
  }
  throw lastError || new Error('backend assertion timed out');
}

async function snapshotPreCreateIds(ctx) {
  if (ctx.__pre_create_ids) return;
  const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  if (!listApiRef) return;
  try {
    const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
    if (!listField) return;
    const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
    const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
    ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
}

async function runCaseWait(page, ctx, waitKey, covers) {
  const entries = [];
  const pushEntry = (entry) => {
    if (!entry) return;
    if (!entries.includes(entry)) entries.push(entry);
  };
  if (waitKey && waitKey !== '__AUTO__') {
    pushEntry(__WAIT_CONTRACT[waitKey]);
  } else if (Array.isArray(covers) && covers.length === 1) {
    pushEntry(__WAIT_CONTRACT[covers[0]]);
  }
  for (const entry of entries) {
    await runWaitEntry(page, ctx, entry);
  }
}

async function executeBackendAssertion(ctx, assertion) {
  if (!assertion || !assertion.api) return;
  const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  await retryBackendAssertion(timeout, async () => {
    if (assertion.api === 'get') {
      const id = resolveBackendAssertionId(ctx, assertion);
      const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
      if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
      const record = payload?.data?.[field];
      const actual = readValueAtPath(record, assertion.path || null);
      if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
      if (assertion.op === 'equals' || assertion.op === 'field_equals') {
        const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
        if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
      }
      applyBindings(ctx, assertion.binds, record);
      refreshDataBindings(ctx);
      return;
    }
    if (assertion.api === 'list') {
      const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
      if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
      const results = payload?.data?.[field]?.results || [];
      if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
      if (assertion.op === 'contains_equals') {
        const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
        const matched = Array.isArray(results)
          ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
          : null;
        if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
        applyBindings(ctx, assertion.binds, matched);
        refreshDataBindings(ctx);
        return;
      }
      if (assertion.op === 'not_contains') {
        const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
        const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
        if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
      }
    }
  });
}

async function captureCreatedRecordId(ctx, caseKind, covers) {
  const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  if (!isCreate) return;
  if (ctx.created_record_id) return;
  const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  if (!listApiRef) return;
  try {
    const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
    if (!listField) return;
    const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
    const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
    const allIds = rows.map((r) => r?.id).filter(Boolean);
    if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
    const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
    const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
    if (matched?.id) {
      ctx.created_record_id = matched.id;
      ctx.__cleanup_queue = ctx.__cleanup_queue || [];
      ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
      refreshDataBindings(ctx);
    }
  } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
}

async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  for (const entry of entries) {
    if (!entry) continue;
    for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
      if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
      if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
      if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
    }
    await executeBackendAssertion(ctx, entry.backend);
  }
}

async function runContractCleanup(ctx) {
  const seedIds = ctx.__seed_ids || new Set();
  const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  for (const entry of dynamicQueue) {
    if (!entry?.id || !entry?.domain || !entry?.entity) continue;
    if (seedIds.has(entry.id)) continue;
    try {
      const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
      if (!field) continue;
      await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
    } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  }
  for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
    if (!item?.api) continue;
    const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
    if (!apiRef) continue;
    const id = resolveCleanupSourceValue(ctx, item.source, item.path);
    if (id == null || id === '') {
      if (item.ignore_missing) continue;
      throw new Error('cleanup source value missing for ' + JSON.stringify(item));
    }
    if (seedIds.has(id)) continue;
    const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
    if (!field) {
      if (item.ignore_missing) continue;
      throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
    }
    const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
    const errors = payload?.errors || payload?.data?.[field]?.errors || [];
    if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
      throw new Error('cleanup mutation failed for ' + String(field));
    }
  }
}

async function waitForLiveViewReady(page, timeout) {
  const root = page.locator('[data-phx-main]');
  await root.waitFor({ state: 'attached', timeout });
  await page.waitForFunction(() => {
    const node = document.querySelector('[data-phx-main]');
    if (!node) return false;
    const cls = node.getAttribute('class') || '';
    return cls.includes('phx-connected') || !cls.includes('phx-loading');
  }, { timeout });
}

function rememberFormValue(ctx, selector, value) {
  const patterns = [
    /\[name=['"]([^'"]+)['"]\]/,
    /#form_([a-zA-Z0-9_]+)/,
    /#(?:[a-zA-Z0-9_]+)_fcl_form_([a-zA-Z0-9_]+)/,
    /#(?:[a-zA-Z0-9_]+)_wizard_step[12]_([a-zA-Z0-9_]+)/,
  ];
  for (const re of patterns) {
    const m = selector.match(re);
    if (m) {
      ctx.form[m[1]] = value;
      refreshDataBindings(ctx);
      return;
    }
  }
}

async function syncRouteContext(page, ctx) {
  const current = new URL(page.url());
  let id = current.searchParams.get('id');
  if (!id) {
    const parts = current.pathname.split('/').filter(Boolean);
    const last = parts[parts.length - 1] || '';
    if (last && last !== 'new' && /^[0-9a-fA-F-]{8,}$/.test(last)) id = last;
  }
  ctx.route = ctx.route || {};
  if (id) {
    ctx.route.id = id;
  } else {
    delete ctx.route.id;
  }
  refreshDataBindings(ctx);
}

function resolveContractUrl(ctx) {
  let path = resolveTemplateString(ctx, "/pages/travel/flight_offer/:id");
  if (path.includes(':id')) {
    const id = ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.route?.id || '';
    if (!id) throw new Error('detail route requires id but no route id is available');
    path = path.replace(':id', id);
  }
  return new URL(path, "http://localhost:4100/").toString();
}

async function ensureSeedRecord(page, __ctx) {
  await ensureContractSetup(page, __ctx);
  await syncRouteContext(page, __ctx);
  const seedId = __ctx.active_record_id || __ctx.route_record_id || __ctx.seed_record_id || __ctx.created_record_id || __ctx.route?.id;
  if (seedId) return;
  throw new Error('detail route requires seed record id from data_contract.setup');
}

test.describe("flight_offer_detail", () => {
  test('E2E flow', async ({ page }) => {
    test.setTimeout(435000);
    const __memo = new Map();
    const __ctx = { form: {}, route: {}, clicked_row: null, active_record_id: null, seed_record_id: null, created_record_id: null, route_record_id: null, __run_id: String(Date.now()) + '_' + Math.random().toString(36).slice(2, 8), __cleanup_queue: [], __seed_ids: new Set() };
    try {
      await ensureContractSetup(page, __ctx);
      await test.step("页面加载 + 结构可见", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
        await runCaseWait(page, __ctx, "load", []);
        await captureCreatedRecordId(__ctx, "load", []);
        await runCaseVerification(page, __ctx, "load", "load", []);
      });
      await test.step("编辑模式切换", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#edit_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#flight_offer_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#cancel_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#flight_offer_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).not.toBeVisible({ timeout: 15000 });
        await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
        await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
        await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
      });
      await test.step("CRUD：编辑记录", async () => {
        await snapshotPreCreateIds(__ctx);
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#edit_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#flight_offer_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#flight_offer_form_arrival_airport_ref_id, [name='arrival_airport_ref_id']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_arrival_airport_ref_id");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["arrival_airport_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_refund_change_policy, [name='refund_change_policy']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_change_policy");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["refund_change_policy"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_listed_price, [name='listed_price']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "200.00");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["listed_price"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_settlement_price, [name='settlement_price']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "200.00");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["settlement_price"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_currency, [name='currency']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_currency");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["currency"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_departure_airport_ref_id, [name='departure_airport_ref_id']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_departure_airport_ref_id");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["departure_airport_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_seats_available, [name='seats_available']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "2");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["seats_available"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_fare_family, [name='fare_family']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_fare_family");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["fare_family"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_form_baggage_policy, [name='baggage_policy']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_baggage_policy");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["baggage_policy"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#flight_offer_edit_form button[type="submit"], #flight_offer_edit_form [phx-click="form_submit"]`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
        await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
        await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
      });
      await test.step("状态转换：draft → active（activate）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_activate}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#flight_offer_action_activate`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_activate"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_activate"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_activate", ["action_activate"]);
        await captureCreatedRecordId(__ctx, "state", ["action_activate"]);
        await runCaseVerification(page, __ctx, "action_activate", "state", ["action_activate"]);
      });
      await test.step("状态转换：active → inactive（deactivate）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_deactivate}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#flight_offer_action_deactivate`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_deactivate"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_deactivate"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_deactivate", ["action_deactivate"]);
        await captureCreatedRecordId(__ctx, "state", ["action_deactivate"]);
        await runCaseVerification(page, __ctx, "action_deactivate", "state", ["action_deactivate"]);
      });
      await test.step("状态转换：active → expired（expire）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_expire}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#flight_offer_action_expire`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_expire"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_expire"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_expire", ["action_expire"]);
        await captureCreatedRecordId(__ctx, "state", ["action_expire"]);
        await runCaseVerification(page, __ctx, "action_expire", "state", ["action_expire"]);
      });
      await test.step("动作：删除", async () => {
        await snapshotPreCreateIds(__ctx);
        if (__ctx.created_record_id) { __ctx.active_record_id = __ctx.created_record_id; }
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#delete_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_destroy"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_destroy"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      {
        const expectedUrl = resolveTemplateString(__ctx, "/pages/travel/flight_offer");
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout: 15000 });
      } catch (e) {
        await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout: 15000 });
      }
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
        await runCaseWait(page, __ctx, "destroy", ["action_destroy"]);
        await captureCreatedRecordId(__ctx, "crud", ["action_destroy"]);
        await runCaseVerification(page, __ctx, "destroy", "crud", ["action_destroy"]);
      });
    } finally {
      await runContractCleanup(__ctx);
    }
  });
});
