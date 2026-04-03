# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: hotel_offer_detail.expanded.spec.ts >> hotel_offer_detail >> E2E flow
- Location: hotel_offer_detail.expanded.spec.ts:1217:7

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
              - paragraph
            - generic [ref=e48]:
              - paragraph [ref=e49]: 酒店编码
              - paragraph
            - generic [ref=e50]:
              - paragraph [ref=e51]: 酒店名称
              - paragraph
            - generic [ref=e52]:
              - paragraph [ref=e53]: 城市编码
              - paragraph
            - generic [ref=e54]:
              - paragraph [ref=e55]: 房型编码
              - paragraph
            - generic [ref=e56]:
              - paragraph [ref=e57]: 价计划编码
              - paragraph
            - generic [ref=e58]:
              - paragraph [ref=e59]: 入住日期
              - paragraph
            - generic [ref=e60]:
              - paragraph [ref=e61]: 离店日期
              - paragraph
            - generic [ref=e62]:
              - paragraph [ref=e63]: 对客展示价快照
              - paragraph
            - generic [ref=e64]:
              - paragraph [ref=e65]: 结算价快照
              - paragraph
            - generic [ref=e66]:
              - paragraph [ref=e67]: 币种
              - paragraph
            - generic [ref=e68]:
              - paragraph [ref=e69]: 可售库存快照
              - paragraph
            - generic [ref=e70]:
              - paragraph [ref=e71]: 取消规则快照
              - paragraph
            - generic [ref=e72]:
              - paragraph [ref=e73]: 担保规则快照
              - paragraph
            - generic [ref=e74]:
              - paragraph [ref=e75]: 可售状态
              - paragraph
```

# Test source

```ts
  1319 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1320 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1321 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1322 |         __ctx.form["listed_price"] = resolvedValue; refreshDataBindings(__ctx);
  1323 |       }
  1324 |       {
  1325 |         const loc = page.locator(`#hotel_offer_form_currency, [name='currency']`).first();
  1326 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1327 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_currency");
  1328 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1329 |         __ctx.form["currency"] = resolvedValue; refreshDataBindings(__ctx);
  1330 |       }
  1331 |       {
  1332 |         const loc = page.locator(`#hotel_offer_form_city_code, [name='city_code']`).first();
  1333 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1334 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_city_code");
  1335 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1336 |         __ctx.form["city_code"] = resolvedValue; refreshDataBindings(__ctx);
  1337 |       }
  1338 |       {
  1339 |         const loc = page.locator(`#hotel_offer_form_guarantee_policy, [name='guarantee_policy']`).first();
  1340 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1341 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_guarantee_policy");
  1342 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1343 |         __ctx.form["guarantee_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1344 |       }
  1345 |       {
  1346 |         const loc = page.locator(`#hotel_offer_form_hotel_name, [name='hotel_name']`).first();
  1347 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1348 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_hotel_name");
  1349 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1350 |         __ctx.form["hotel_name"] = resolvedValue; refreshDataBindings(__ctx);
  1351 |       }
  1352 |       {
  1353 |         const loc = page.locator(`#hotel_offer_form_city_ref_id, [name='city_ref_id']`).first();
  1354 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1355 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_city_ref_id");
  1356 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1357 |         __ctx.form["city_ref_id"] = resolvedValue; refreshDataBindings(__ctx);
  1358 |       }
  1359 |       {
  1360 |         const loc = page.locator(`#hotel_offer_form_settlement_price, [name='settlement_price']`).first();
  1361 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1362 |         const resolvedValue = resolveTemplateString(__ctx, "200.00");
  1363 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1364 |         __ctx.form["settlement_price"] = resolvedValue; refreshDataBindings(__ctx);
  1365 |       }
  1366 |       {
  1367 |         const loc = page.locator(`#hotel_offer_form_inventory_count, [name='inventory_count']`).first();
  1368 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1369 |         const resolvedValue = resolveTemplateString(__ctx, "2");
  1370 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1371 |         __ctx.form["inventory_count"] = resolvedValue; refreshDataBindings(__ctx);
  1372 |       }
  1373 |       {
  1374 |         const loc = page.locator(`#hotel_offer_form_cancellation_policy, [name='cancellation_policy']`).first();
  1375 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1376 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_cancellation_policy");
  1377 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1378 |         __ctx.form["cancellation_policy"] = resolvedValue; refreshDataBindings(__ctx);
  1379 |       }
  1380 |       {
  1381 |         const loc = page.locator(`#hotel_offer_edit_form button[type="submit"], #hotel_offer_edit_form [phx-click="form_submit"]`).first();
  1382 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1383 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1384 |         const confirmText = await loc.getAttribute('data-confirm');
  1385 |         await loc.scrollIntoViewIfNeeded();
  1386 |         if (confirmText) {
  1387 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1388 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1389 |             .catch(() => null);
  1390 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1391 |           await dialogPromise;
  1392 |         } else {
  1393 |           await loc.click({ timeout: 15000 });
  1394 |         }
  1395 |         if (clickedId) {
  1396 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1397 |           refreshDataBindings(__ctx);
  1398 |         }
  1399 |         await waitForLiveViewReady(page, 15000);
  1400 |         await syncRouteContext(page, __ctx);
  1401 |       }
  1402 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1403 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1404 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1405 |       });
  1406 |       await test.step("状态转换：draft → active（activate）", async () => {
  1407 |       {
  1408 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_activate}}");
  1409 |         const target = /^https?:\/\//.test(targetValue)
  1410 |           ? targetValue
  1411 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1412 |         await page.goto(target);
  1413 |       }
  1414 |       await waitForLiveViewReady(page, 15000);
  1415 |       await syncRouteContext(page, __ctx);
  1416 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1417 |       {
  1418 |         const loc = page.locator(`#hotel_offer_action_activate`).first();
> 1419 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1420 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1421 |         const confirmText = await loc.getAttribute('data-confirm');
  1422 |         await loc.scrollIntoViewIfNeeded();
  1423 |         if (confirmText) {
  1424 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1425 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1426 |             .catch(() => null);
  1427 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1428 |           await dialogPromise;
  1429 |         } else {
  1430 |           await loc.click({ timeout: 15000 });
  1431 |         }
  1432 |         if (clickedId) {
  1433 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1434 |           __ctx["state_action_record_id_activate"] = clickedId;
  1435 |           refreshDataBindings(__ctx);
  1436 |         }
  1437 |         if (!clickedId) {
  1438 |           __ctx["state_action_record_id_activate"] = defaultRecordId(__ctx);
  1439 |         }
  1440 |         await waitForLiveViewReady(page, 15000);
  1441 |         await syncRouteContext(page, __ctx);
  1442 |       }
  1443 |         await runCaseWait(page, __ctx, "action_activate", ["action_activate"]);
  1444 |         await captureCreatedRecordId(__ctx, "state", ["action_activate"]);
  1445 |         await runCaseVerification(page, __ctx, "action_activate", "state", ["action_activate"]);
  1446 |       });
  1447 |       await test.step("状态转换：active → inactive（deactivate）", async () => {
  1448 |       {
  1449 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_deactivate}}");
  1450 |         const target = /^https?:\/\//.test(targetValue)
  1451 |           ? targetValue
  1452 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1453 |         await page.goto(target);
  1454 |       }
  1455 |       await waitForLiveViewReady(page, 15000);
  1456 |       await syncRouteContext(page, __ctx);
  1457 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1458 |       {
  1459 |         const loc = page.locator(`#hotel_offer_action_deactivate`).first();
  1460 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1461 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1462 |         const confirmText = await loc.getAttribute('data-confirm');
  1463 |         await loc.scrollIntoViewIfNeeded();
  1464 |         if (confirmText) {
  1465 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1466 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1467 |             .catch(() => null);
  1468 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1469 |           await dialogPromise;
  1470 |         } else {
  1471 |           await loc.click({ timeout: 15000 });
  1472 |         }
  1473 |         if (clickedId) {
  1474 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1475 |           __ctx["state_action_record_id_deactivate"] = clickedId;
  1476 |           refreshDataBindings(__ctx);
  1477 |         }
  1478 |         if (!clickedId) {
  1479 |           __ctx["state_action_record_id_deactivate"] = defaultRecordId(__ctx);
  1480 |         }
  1481 |         await waitForLiveViewReady(page, 15000);
  1482 |         await syncRouteContext(page, __ctx);
  1483 |       }
  1484 |         await runCaseWait(page, __ctx, "action_deactivate", ["action_deactivate"]);
  1485 |         await captureCreatedRecordId(__ctx, "state", ["action_deactivate"]);
  1486 |         await runCaseVerification(page, __ctx, "action_deactivate", "state", ["action_deactivate"]);
  1487 |       });
  1488 |       await test.step("状态转换：active → expired（expire）", async () => {
  1489 |       {
  1490 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/hotel_offer/{{state_action_record_id_expire}}");
  1491 |         const target = /^https?:\/\//.test(targetValue)
  1492 |           ? targetValue
  1493 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1494 |         await page.goto(target);
  1495 |       }
  1496 |       await waitForLiveViewReady(page, 15000);
  1497 |       await syncRouteContext(page, __ctx);
  1498 |       await expect(page.locator(`#hotel_offer_detail`)).toBeVisible({ timeout: 15000 });
  1499 |       {
  1500 |         const loc = page.locator(`#hotel_offer_action_expire`).first();
  1501 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1502 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1503 |         const confirmText = await loc.getAttribute('data-confirm');
  1504 |         await loc.scrollIntoViewIfNeeded();
  1505 |         if (confirmText) {
  1506 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1507 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1508 |             .catch(() => null);
  1509 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1510 |           await dialogPromise;
  1511 |         } else {
  1512 |           await loc.click({ timeout: 15000 });
  1513 |         }
  1514 |         if (clickedId) {
  1515 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1516 |           __ctx["state_action_record_id_expire"] = clickedId;
  1517 |           refreshDataBindings(__ctx);
  1518 |         }
  1519 |         if (!clickedId) {
```