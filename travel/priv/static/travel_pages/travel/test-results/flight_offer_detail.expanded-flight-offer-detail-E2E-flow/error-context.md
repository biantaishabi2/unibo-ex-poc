# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: flight_offer_detail.expanded.spec.ts >> flight_offer_detail >> E2E flow
- Location: flight_offer_detail.expanded.spec.ts:1220:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#flight_offer_action_activate').first() to be visible

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
            - paragraph [ref=e33]: FlightOffer
            - paragraph [ref=e34]: 机票可售 offer,承载航班、舱位、票规和库存快照
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
              - paragraph [ref=e49]: 行程编码
              - paragraph
            - generic [ref=e50]:
              - paragraph [ref=e51]: 航班号
              - paragraph
            - generic [ref=e52]:
              - paragraph [ref=e53]: 出发机场编码
              - paragraph
            - generic [ref=e54]:
              - paragraph [ref=e55]: 到达机场编码
              - paragraph
            - generic [ref=e56]:
              - paragraph [ref=e57]: 起飞时间
              - paragraph
            - generic [ref=e58]:
              - paragraph [ref=e59]: 到达时间
              - paragraph
            - generic [ref=e60]:
              - paragraph [ref=e61]: 舱等
              - paragraph
            - generic [ref=e62]:
              - paragraph [ref=e63]: 运价族
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
              - paragraph [ref=e71]: 可售座位快照
              - paragraph
            - generic [ref=e72]:
              - paragraph [ref=e73]: 行李规则快照
              - paragraph
            - generic [ref=e74]:
              - paragraph [ref=e75]: 退改规则快照
              - paragraph
            - generic [ref=e76]:
              - paragraph [ref=e77]: sale_status
              - paragraph
```

# Test source

```ts
  1322 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1323 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_currency");
  1324 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1325 |         __ctx.form["currency"] = resolvedValue; refreshDataBindings(__ctx);
  1326 |       }
  1327 |       {
  1328 |         const loc = page.locator(`#flight_offer_form_departure_airport_ref_id, [name='departure_airport_ref_id']`).first();
  1329 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1330 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_departure_airport_ref_id");
  1331 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1332 |         __ctx.form["departure_airport_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1333 |       }
  1334 |       {
  1335 |         const loc = page.locator(`#flight_offer_form_settlement_price, [name='settlement_price']`).first();
  1336 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1337 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1338 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1339 |         __ctx.form["settlement_price"] = resolvedValue; refreshDataBindings(__ctx);
  1340 |       }
  1341 |       {
  1342 |         const loc = page.locator(`#flight_offer_form_baggage_policy, [name='baggage_policy']`).first();
  1343 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1344 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_baggage_policy");
  1345 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1346 |         __ctx.form["baggage_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1347 |       }
  1348 |       {
  1349 |         const loc = page.locator(`#flight_offer_form_refund_change_policy, [name='refund_change_policy']`).first();
  1350 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1351 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_change_policy");
  1352 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1353 |         __ctx.form["refund_change_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1354 |       }
  1355 |       {
  1356 |         const loc = page.locator(`#flight_offer_form_seats_available, [name='seats_available']`).first();
  1357 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1358 |         const resolvedValue = resolveTemplateString(__ctx, "2");
  1359 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1360 |         __ctx.form["seats_available"] = resolvedValue; refreshDataBindings(__ctx);
  1361 |       }
  1362 |       {
  1363 |         const loc = page.locator(`#flight_offer_form_arrival_airport_ref_id, [name='arrival_airport_ref_id']`).first();
  1364 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1365 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_arrival_airport_ref_id");
  1366 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1367 |         __ctx.form["arrival_airport_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1368 |       }
  1369 |       {
  1370 |         const loc = page.locator(`#flight_offer_form_fare_family, [name='fare_family']`).first();
  1371 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1372 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_fare_family");
  1373 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1374 |         __ctx.form["fare_family"] = resolvedValue; refreshDataBindings(__ctx);
  1375 |       }
  1376 |       {
  1377 |         const loc = page.locator(`#flight_offer_form_listed_price, [name='listed_price']`).first();
  1378 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1379 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1380 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1381 |         __ctx.form["listed_price"] = resolvedValue; refreshDataBindings(__ctx);
  1382 |       }
  1383 |       {
  1384 |         const loc = page.locator(`#flight_offer_edit_form button[type="submit"], #flight_offer_edit_form [phx-click="form_submit"]`).first();
  1385 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1386 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1387 |         const confirmText = await loc.getAttribute('data-confirm');
  1388 |         await loc.scrollIntoViewIfNeeded();
  1389 |         if (confirmText) {
  1390 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1391 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1392 |             .catch(() => null);
  1393 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1394 |           await dialogPromise;
  1395 |         } else {
  1396 |           await loc.click({ timeout: 15000 });
  1397 |         }
  1398 |         if (clickedId) {
  1399 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1400 |           refreshDataBindings(__ctx);
  1401 |         }
  1402 |         await waitForLiveViewReady(page, 15000);
  1403 |         await syncRouteContext(page, __ctx);
  1404 |       }
  1405 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1406 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1407 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1408 |       });
  1409 |       await test.step("状态转换：draft → active（activate）", async () => {
  1410 |       {
  1411 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_activate}}");
  1412 |         const target = /^https?:\/\//.test(targetValue)
  1413 |           ? targetValue
  1414 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1415 |         await page.goto(target);
  1416 |       }
  1417 |       await waitForLiveViewReady(page, 15000);
  1418 |       await syncRouteContext(page, __ctx);
  1419 |       await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
  1420 |       {
  1421 |         const loc = page.locator(`#flight_offer_action_activate`).first();
> 1422 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1423 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1424 |         const confirmText = await loc.getAttribute('data-confirm');
  1425 |         await loc.scrollIntoViewIfNeeded();
  1426 |         if (confirmText) {
  1427 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1428 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1429 |             .catch(() => null);
  1430 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1431 |           await dialogPromise;
  1432 |         } else {
  1433 |           await loc.click({ timeout: 15000 });
  1434 |         }
  1435 |         if (clickedId) {
  1436 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1437 |           __ctx["state_action_record_id_activate"] = clickedId;
  1438 |           refreshDataBindings(__ctx);
  1439 |         }
  1440 |         if (!clickedId) {
  1441 |           __ctx["state_action_record_id_activate"] = defaultRecordId(__ctx);
  1442 |         }
  1443 |         await waitForLiveViewReady(page, 15000);
  1444 |         await syncRouteContext(page, __ctx);
  1445 |       }
  1446 |         await runCaseWait(page, __ctx, "action_activate", ["action_activate"]);
  1447 |         await captureCreatedRecordId(__ctx, "state", ["action_activate"]);
  1448 |         await runCaseVerification(page, __ctx, "action_activate", "state", ["action_activate"]);
  1449 |       });
  1450 |       await test.step("状态转换：active → inactive（deactivate）", async () => {
  1451 |       {
  1452 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_deactivate}}");
  1453 |         const target = /^https?:\/\//.test(targetValue)
  1454 |           ? targetValue
  1455 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1456 |         await page.goto(target);
  1457 |       }
  1458 |       await waitForLiveViewReady(page, 15000);
  1459 |       await syncRouteContext(page, __ctx);
  1460 |       await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
  1461 |       {
  1462 |         const loc = page.locator(`#flight_offer_action_deactivate`).first();
  1463 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1464 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1465 |         const confirmText = await loc.getAttribute('data-confirm');
  1466 |         await loc.scrollIntoViewIfNeeded();
  1467 |         if (confirmText) {
  1468 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1469 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1470 |             .catch(() => null);
  1471 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1472 |           await dialogPromise;
  1473 |         } else {
  1474 |           await loc.click({ timeout: 15000 });
  1475 |         }
  1476 |         if (clickedId) {
  1477 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1478 |           __ctx["state_action_record_id_deactivate"] = clickedId;
  1479 |           refreshDataBindings(__ctx);
  1480 |         }
  1481 |         if (!clickedId) {
  1482 |           __ctx["state_action_record_id_deactivate"] = defaultRecordId(__ctx);
  1483 |         }
  1484 |         await waitForLiveViewReady(page, 15000);
  1485 |         await syncRouteContext(page, __ctx);
  1486 |       }
  1487 |         await runCaseWait(page, __ctx, "action_deactivate", ["action_deactivate"]);
  1488 |         await captureCreatedRecordId(__ctx, "state", ["action_deactivate"]);
  1489 |         await runCaseVerification(page, __ctx, "action_deactivate", "state", ["action_deactivate"]);
  1490 |       });
  1491 |       await test.step("状态转换：active → expired（expire）", async () => {
  1492 |       {
  1493 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/flight_offer/{{state_action_record_id_expire}}");
  1494 |         const target = /^https?:\/\//.test(targetValue)
  1495 |           ? targetValue
  1496 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1497 |         await page.goto(target);
  1498 |       }
  1499 |       await waitForLiveViewReady(page, 15000);
  1500 |       await syncRouteContext(page, __ctx);
  1501 |       await expect(page.locator(`#flight_offer_detail`)).toBeVisible({ timeout: 15000 });
  1502 |       {
  1503 |         const loc = page.locator(`#flight_offer_action_expire`).first();
  1504 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1505 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1506 |         const confirmText = await loc.getAttribute('data-confirm');
  1507 |         await loc.scrollIntoViewIfNeeded();
  1508 |         if (confirmText) {
  1509 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1510 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1511 |             .catch(() => null);
  1512 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1513 |           await dialogPromise;
  1514 |         } else {
  1515 |           await loc.click({ timeout: 15000 });
  1516 |         }
  1517 |         if (clickedId) {
  1518 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1519 |           __ctx["state_action_record_id_expire"] = clickedId;
  1520 |           refreshDataBindings(__ctx);
  1521 |         }
  1522 |         if (!clickedId) {
```