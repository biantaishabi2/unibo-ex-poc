# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: hotel_offer_detail.expanded.spec.ts >> hotel_offer_detail >> E2E flow
- Location: hotel_offer_detail.expanded.spec.ts:1216:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#hotel_offer_action_activate').first() to be visible

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
            - paragraph [ref=e33]: HotelOffer
            - paragraph [ref=e34]: 酒店可售 offer,承载房型、价计划、价态和可售规则快照
          - generic [ref=e36]:
            - button "编辑" [ref=e37] [cursor=pointer]
            - button "删除" [ref=e38] [cursor=pointer]
        - generic [ref=e40]:
          - heading "基本信息" [level=3] [ref=e42]
          - generic [ref=e45]:
            - generic [ref=e46]:
              - paragraph [ref=e47]: 供应商编码
              - paragraph [ref=e48]: supplier_code_003
            - generic [ref=e49]:
              - paragraph [ref=e50]: 酒店编码
              - paragraph [ref=e51]: hotel_code_003
            - generic [ref=e52]:
              - paragraph [ref=e53]: 酒店名称
              - paragraph [ref=e54]: UPDATED_1775257572303_ovqdyj_hotel_name
            - generic [ref=e55]:
              - paragraph [ref=e56]: 城市编码
              - paragraph [ref=e57]: UPDATED_1775257572303_ovqdyj_city_code
            - generic [ref=e58]:
              - paragraph [ref=e59]: 房型编码
              - paragraph [ref=e60]: room_type_code_003
            - generic [ref=e61]:
              - paragraph [ref=e62]: 价计划编码
              - paragraph [ref=e63]: rate_plan_code_003
            - generic [ref=e64]:
              - paragraph [ref=e65]: 入住日期
              - paragraph [ref=e66]: 2026-01-01
            - generic [ref=e67]:
              - paragraph [ref=e68]: 离店日期
              - paragraph [ref=e69]: 2026-01-01
            - generic [ref=e70]:
              - paragraph [ref=e71]: 对客展示价快照
              - paragraph [ref=e72]: "200.00"
            - generic [ref=e73]:
              - paragraph [ref=e74]: 结算价快照
              - paragraph [ref=e75]: "200.00"
            - generic [ref=e76]:
              - paragraph [ref=e77]: 币种
              - paragraph [ref=e78]: UPDATED_1775257572303_ovqdyj_currency
            - generic [ref=e79]:
              - paragraph [ref=e80]: 可售库存快照
              - paragraph
            - generic [ref=e81]:
              - paragraph [ref=e82]: 取消规则快照
              - paragraph [ref=e83]: UPDATED_1775257572303_ovqdyj_cancellation_policy
            - generic [ref=e84]:
              - paragraph [ref=e85]: 担保规则快照
              - paragraph [ref=e86]: UPDATED_1775257572303_ovqdyj_guarantee_policy
            - generic [ref=e87]:
              - paragraph [ref=e88]: 可售状态
              - paragraph [ref=e89]: active
```

# Test source

```ts
  1318 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1319 |         const resolvedValue = resolveTemplateString(__ctx, "2");
  1320 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1321 |         __ctx.form["inventory_count"] = resolvedValue; refreshDataBindings(__ctx);
  1322 |       }
  1323 |       {
  1324 |         const loc = page.locator(`#hotel_offer_form_listed_price, [name='listed_price']`).first();
  1325 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1326 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1327 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1328 |         __ctx.form["listed_price"] = resolvedValue; refreshDataBindings(__ctx);
  1329 |       }
  1330 |       {
  1331 |         const loc = page.locator(`#hotel_offer_form_hotel_name, [name='hotel_name']`).first();
  1332 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1333 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_hotel_name");
  1334 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1335 |         __ctx.form["hotel_name"] = resolvedValue; refreshDataBindings(__ctx);
  1336 |       }
  1337 |       {
  1338 |         const loc = page.locator(`#hotel_offer_form_city_ref_id, [name='city_ref_id']`).first();
  1339 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1340 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_city_ref_id");
  1341 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1342 |         __ctx.form["city_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1343 |       }
  1344 |       {
  1345 |         const loc = page.locator(`#hotel_offer_form_currency, [name='currency']`).first();
  1346 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1347 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_currency");
  1348 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1349 |         __ctx.form["currency"] = resolvedValue; refreshDataBindings(__ctx);
  1350 |       }
  1351 |       {
  1352 |         const loc = page.locator(`#hotel_offer_form_settlement_price, [name='settlement_price']`).first();
  1353 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1354 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1355 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1356 |         __ctx.form["settlement_price"] = resolvedValue; refreshDataBindings(__ctx);
  1357 |       }
  1358 |       {
  1359 |         const loc = page.locator(`#hotel_offer_form_cancellation_policy, [name='cancellation_policy']`).first();
  1360 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1361 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_cancellation_policy");
  1362 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1363 |         __ctx.form["cancellation_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1364 |       }
  1365 |       {
  1366 |         const loc = page.locator(`#hotel_offer_form_guarantee_policy, [name='guarantee_policy']`).first();
  1367 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1368 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_guarantee_policy");
  1369 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1370 |         __ctx.form["guarantee_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1371 |       }
  1372 |       {
  1373 |         const loc = page.locator(`#hotel_offer_form_city_code, [name='city_code']`).first();
  1374 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1375 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_city_code");
  1376 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1377 |         __ctx.form["city_code"] = resolvedValue; refreshDataBindings(__ctx);
  1378 |       }
  1379 |       {
  1380 |         const loc = page.locator(`#hotel_offer_edit_form button[type="submit"], #hotel_offer_edit_form [phx-click="form_submit"]`).first();
  1381 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1382 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1383 |         const confirmText = await loc.getAttribute('data-confirm');
  1384 |         await loc.scrollIntoViewIfNeeded();
  1385 |         if (confirmText) {
  1386 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1387 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1388 |             .catch(() => null);
  1389 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1390 |           await dialogPromise;
  1391 |         } else {
  1392 |           await loc.click({ timeout: 15000 });
  1393 |         }
  1394 |         if (clickedId) {
  1395 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1396 |           refreshDataBindings(__ctx);
  1397 |         }
  1398 |         await waitForLiveViewReady(page, 15000);
  1399 |         await syncRouteContext(page, __ctx);
  1400 |       }
  1401 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1402 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1403 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1404 |       });
  1405 |       await test.step("状态转换：draft → active（activate）", async () => {
  1406 |       {
  1407 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_activate}}");
  1408 |         const target = /^https?:\/\//.test(targetValue)
  1409 |           ? targetValue
  1410 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1411 |         await page.goto(target);
  1412 |       }
  1413 |       await waitForLiveViewReady(page, 15000);
  1414 |       await syncRouteContext(page, __ctx);
  1415 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1416 |       {
  1417 |         const loc = page.locator(`#hotel_offer_action_activate`).first();
> 1418 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1419 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1420 |         const confirmText = await loc.getAttribute('data-confirm');
  1421 |         await loc.scrollIntoViewIfNeeded();
  1422 |         if (confirmText) {
  1423 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1424 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1425 |             .catch(() => null);
  1426 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1427 |           await dialogPromise;
  1428 |         } else {
  1429 |           await loc.click({ timeout: 15000 });
  1430 |         }
  1431 |         if (clickedId) {
  1432 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1433 |           __ctx["state_action_record_id_activate"] = clickedId;
  1434 |           refreshDataBindings(__ctx);
  1435 |         }
  1436 |         if (!clickedId) {
  1437 |           __ctx["state_action_record_id_activate"] = defaultRecordId(__ctx);
  1438 |         }
  1439 |         await waitForLiveViewReady(page, 15000);
  1440 |         await syncRouteContext(page, __ctx);
  1441 |       }
  1442 |         await runCaseWait(page, __ctx, "action_activate", ["action_activate"]);
  1443 |         await captureCreatedRecordId(__ctx, "state", ["action_activate"]);
  1444 |         await runCaseVerification(page, __ctx, "action_activate", "state", ["action_activate"]);
  1445 |       });
  1446 |       await test.step("状态转换：active → inactive（deactivate）", async () => {
  1447 |       {
  1448 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_deactivate}}");
  1449 |         const target = /^https?:\/\//.test(targetValue)
  1450 |           ? targetValue
  1451 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1452 |         await page.goto(target);
  1453 |       }
  1454 |       await waitForLiveViewReady(page, 15000);
  1455 |       await syncRouteContext(page, __ctx);
  1456 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1457 |       {
  1458 |         const loc = page.locator(`#hotel_offer_action_deactivate`).first();
  1459 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1460 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1461 |         const confirmText = await loc.getAttribute('data-confirm');
  1462 |         await loc.scrollIntoViewIfNeeded();
  1463 |         if (confirmText) {
  1464 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1465 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1466 |             .catch(() => null);
  1467 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1468 |           await dialogPromise;
  1469 |         } else {
  1470 |           await loc.click({ timeout: 15000 });
  1471 |         }
  1472 |         if (clickedId) {
  1473 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1474 |           __ctx["state_action_record_id_deactivate"] = clickedId;
  1475 |           refreshDataBindings(__ctx);
  1476 |         }
  1477 |         if (!clickedId) {
  1478 |           __ctx["state_action_record_id_deactivate"] = defaultRecordId(__ctx);
  1479 |         }
  1480 |         await waitForLiveViewReady(page, 15000);
  1481 |         await syncRouteContext(page, __ctx);
  1482 |       }
  1483 |         await runCaseWait(page, __ctx, "action_deactivate", ["action_deactivate"]);
  1484 |         await captureCreatedRecordId(__ctx, "state", ["action_deactivate"]);
  1485 |         await runCaseVerification(page, __ctx, "action_deactivate", "state", ["action_deactivate"]);
  1486 |       });
  1487 |       await test.step("状态转换：active → expired（expire）", async () => {
  1488 |       {
  1489 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_expire}}");
  1490 |         const target = /^https?:\/\//.test(targetValue)
  1491 |           ? targetValue
  1492 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1493 |         await page.goto(target);
  1494 |       }
  1495 |       await waitForLiveViewReady(page, 15000);
  1496 |       await syncRouteContext(page, __ctx);
  1497 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1498 |       {
  1499 |         const loc = page.locator(`#hotel_offer_action_expire`).first();
  1500 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1501 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1502 |         const confirmText = await loc.getAttribute('data-confirm');
  1503 |         await loc.scrollIntoViewIfNeeded();
  1504 |         if (confirmText) {
  1505 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1506 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1507 |             .catch(() => null);
  1508 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1509 |           await dialogPromise;
  1510 |         } else {
  1511 |           await loc.click({ timeout: 15000 });
  1512 |         }
  1513 |         if (clickedId) {
  1514 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1515 |           __ctx["state_action_record_id_expire"] = clickedId;
  1516 |           refreshDataBindings(__ctx);
  1517 |         }
  1518 |         if (!clickedId) {
```