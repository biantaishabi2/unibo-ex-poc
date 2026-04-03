# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: vacation_offer_detail.expanded.spec.ts >> vacation_offer_detail >> E2E flow
- Location: vacation_offer_detail.expanded.spec.ts:1217:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#vacation_offer_action_activate').first() to be visible

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
            - button "删除" [ref=e38] [cursor=pointer]
        - generic [ref=e40]:
          - heading "基本信息" [level=3] [ref=e42]
          - generic [ref=e45]:
            - generic [ref=e46]:
              - paragraph [ref=e47]: 供应商编码
              - paragraph
            - generic [ref=e48]:
              - paragraph [ref=e49]: 套餐编码
              - paragraph
            - generic [ref=e50]:
              - paragraph [ref=e51]: 套餐名称
              - paragraph
            - generic [ref=e52]:
              - paragraph [ref=e53]: 套餐类型
              - paragraph
            - generic [ref=e54]:
              - paragraph [ref=e55]: 出发城市编码
              - paragraph
            - generic [ref=e56]:
              - paragraph [ref=e57]: 目的地编码
              - paragraph
            - generic [ref=e58]:
              - paragraph [ref=e59]: 出行开始日期
              - paragraph
            - generic [ref=e60]:
              - paragraph [ref=e61]: 出行结束日期
              - paragraph
            - generic [ref=e62]:
              - paragraph [ref=e63]: 对客展示价快照
              - paragraph
            - generic [ref=e64]:
              - paragraph [ref=e65]: 结算价快照
              - paragraph
            - generic [ref=e66]:
              - paragraph [ref=e67]: currency
              - paragraph
            - generic [ref=e68]:
              - paragraph [ref=e69]: 可售库存快照
              - paragraph
            - generic [ref=e70]:
              - paragraph [ref=e71]: 预订规则快照
              - paragraph
            - generic [ref=e72]:
              - paragraph [ref=e73]: 取消规则快照
              - paragraph
            - generic [ref=e74]:
              - paragraph [ref=e75]: sale_status
              - paragraph
```

# Test source

```ts
  1335 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1336 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_destination_ref_id");
  1337 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1338 |         __ctx.form["destination_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1339 |       }
  1340 |       {
  1341 |         const loc = page.locator(`#vacation_offer_form_departure_city_ref_id, [name='departure_city_ref_id']`).first();
  1342 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1343 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_departure_city_ref_id");
  1344 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1345 |         __ctx.form["departure_city_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1346 |       }
  1347 |       {
  1348 |         const loc = page.locator(`#vacation_offer_form_settlement_price, [name='settlement_price']`).first();
  1349 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1350 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1351 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1352 |         __ctx.form["settlement_price"] = resolvedValue; refreshDataBindings(__ctx);
  1353 |       }
  1354 |       {
  1355 |         const loc = page.locator(`#vacation_offer_form_currency, [name='currency']`).first();
  1356 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1357 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_currency");
  1358 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1359 |         __ctx.form["currency"] = resolvedValue; refreshDataBindings(__ctx);
  1360 |       }
  1361 |       {
  1362 |         const loc = page.locator(`#vacation_offer_form_inventory_count, [name='inventory_count']`).first();
  1363 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1364 |         const resolvedValue = resolveTemplateString(__ctx, "2");
  1365 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1366 |         __ctx.form["inventory_count"] = resolvedValue; refreshDataBindings(__ctx);
  1367 |       }
  1368 |       {
  1369 |         const loc = page.locator(`#vacation_offer_form_package_name, [name='package_name']`).first();
  1370 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1371 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_package_name");
  1372 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1373 |         __ctx.form["package_name"] = resolvedValue; refreshDataBindings(__ctx);
  1374 |       }
  1375 |       {
  1376 |         const loc = page.locator(`#vacation_offer_form_cancellation_policy, [name='cancellation_policy']`).first();
  1377 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1378 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_cancellation_policy");
  1379 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1380 |         __ctx.form["cancellation_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1381 |       }
  1382 |       {
  1383 |         const loc = page.locator(`#vacation_offer_form_booking_rules, [name='booking_rules']`).first();
  1384 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1385 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_booking_rules");
  1386 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1387 |         __ctx.form["booking_rules"] = resolvedValue; refreshDataBindings(__ctx);
  1388 |       }
  1389 |       {
  1390 |         const loc = page.locator(`#vacation_offer_form_listed_price, [name='listed_price']`).first();
  1391 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1392 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1393 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1394 |         __ctx.form["listed_price"] = resolvedValue; refreshDataBindings(__ctx);
  1395 |       }
  1396 |       {
  1397 |         const loc = page.locator(`#vacation_offer_edit_form button[type="submit"], #vacation_offer_edit_form [phx-click="form_submit"]`).first();
  1398 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1399 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1400 |         const confirmText = await loc.getAttribute('data-confirm');
  1401 |         await loc.scrollIntoViewIfNeeded();
  1402 |         if (confirmText) {
  1403 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1404 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1405 |             .catch(() => null);
  1406 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1407 |           await dialogPromise;
  1408 |         } else {
  1409 |           await loc.click({ timeout: 15000 });
  1410 |         }
  1411 |         if (clickedId) {
  1412 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1413 |           refreshDataBindings(__ctx);
  1414 |         }
  1415 |         await waitForLiveViewReady(page, 15000);
  1416 |         await syncRouteContext(page, __ctx);
  1417 |       }
  1418 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1419 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1420 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1421 |       });
  1422 |       await test.step("状态转换：draft → active（activate）", async () => {
  1423 |       {
  1424 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/vacation_offer/{{state_action_record_id_activate}}");
  1425 |         const target = /^https?:\/\//.test(targetValue)
  1426 |           ? targetValue
  1427 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1428 |         await page.goto(target);
  1429 |       }
  1430 |       await waitForLiveViewReady(page, 15000);
  1431 |       await syncRouteContext(page, __ctx);
  1432 |       await expect(page.locator(`#vacation_offer_detail`)).toBeVisible({ timeout: 15000 });
  1433 |       {
  1434 |         const loc = page.locator(`#vacation_offer_action_activate`).first();
> 1435 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1436 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1437 |         const confirmText = await loc.getAttribute('data-confirm');
  1438 |         await loc.scrollIntoViewIfNeeded();
  1439 |         if (confirmText) {
  1440 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1441 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1442 |             .catch(() => null);
  1443 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1444 |           await dialogPromise;
  1445 |         } else {
  1446 |           await loc.click({ timeout: 15000 });
  1447 |         }
  1448 |         if (clickedId) {
  1449 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1450 |           __ctx["state_action_record_id_activate"] = clickedId;
  1451 |           refreshDataBindings(__ctx);
  1452 |         }
  1453 |         if (!clickedId) {
  1454 |           __ctx["state_action_record_id_activate"] = defaultRecordId(__ctx);
  1455 |         }
  1456 |         await waitForLiveViewReady(page, 15000);
  1457 |         await syncRouteContext(page, __ctx);
  1458 |       }
  1459 |         await runCaseWait(page, __ctx, "action_activate", ["action_activate"]);
  1460 |         await captureCreatedRecordId(__ctx, "state", ["action_activate"]);
  1461 |         await runCaseVerification(page, __ctx, "action_activate", "state", ["action_activate"]);
  1462 |       });
  1463 |       await test.step("状态转换：active → inactive（deactivate）", async () => {
  1464 |       {
  1465 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/vacation_offer/{{state_action_record_id_deactivate}}");
  1466 |         const target = /^https?:\/\//.test(targetValue)
  1467 |           ? targetValue
  1468 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1469 |         await page.goto(target);
  1470 |       }
  1471 |       await waitForLiveViewReady(page, 15000);
  1472 |       await syncRouteContext(page, __ctx);
  1473 |       await expect(page.locator(`#vacation_offer_detail`)).toBeVisible({ timeout: 15000 });
  1474 |       {
  1475 |         const loc = page.locator(`#vacation_offer_action_deactivate`).first();
  1476 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1477 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1478 |         const confirmText = await loc.getAttribute('data-confirm');
  1479 |         await loc.scrollIntoViewIfNeeded();
  1480 |         if (confirmText) {
  1481 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1482 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1483 |             .catch(() => null);
  1484 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1485 |           await dialogPromise;
  1486 |         } else {
  1487 |           await loc.click({ timeout: 15000 });
  1488 |         }
  1489 |         if (clickedId) {
  1490 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1491 |           __ctx["state_action_record_id_deactivate"] = clickedId;
  1492 |           refreshDataBindings(__ctx);
  1493 |         }
  1494 |         if (!clickedId) {
  1495 |           __ctx["state_action_record_id_deactivate"] = defaultRecordId(__ctx);
  1496 |         }
  1497 |         await waitForLiveViewReady(page, 15000);
  1498 |         await syncRouteContext(page, __ctx);
  1499 |       }
  1500 |         await runCaseWait(page, __ctx, "action_deactivate", ["action_deactivate"]);
  1501 |         await captureCreatedRecordId(__ctx, "state", ["action_deactivate"]);
  1502 |         await runCaseVerification(page, __ctx, "action_deactivate", "state", ["action_deactivate"]);
  1503 |       });
  1504 |       await test.step("状态转换：active → expired（expire）", async () => {
  1505 |       {
  1506 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/vacation_offer/{{state_action_record_id_expire}}");
  1507 |         const target = /^https?:\/\//.test(targetValue)
  1508 |           ? targetValue
  1509 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1510 |         await page.goto(target);
  1511 |       }
  1512 |       await waitForLiveViewReady(page, 15000);
  1513 |       await syncRouteContext(page, __ctx);
  1514 |       await expect(page.locator(`#vacation_offer_detail`)).toBeVisible({ timeout: 15000 });
  1515 |       {
  1516 |         const loc = page.locator(`#vacation_offer_action_expire`).first();
  1517 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1518 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1519 |         const confirmText = await loc.getAttribute('data-confirm');
  1520 |         await loc.scrollIntoViewIfNeeded();
  1521 |         if (confirmText) {
  1522 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1523 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1524 |             .catch(() => null);
  1525 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1526 |           await dialogPromise;
  1527 |         } else {
  1528 |           await loc.click({ timeout: 15000 });
  1529 |         }
  1530 |         if (clickedId) {
  1531 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1532 |           __ctx["state_action_record_id_expire"] = clickedId;
  1533 |           refreshDataBindings(__ctx);
  1534 |         }
  1535 |         if (!clickedId) {
```