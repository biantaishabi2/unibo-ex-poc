# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_change_order_detail.expanded.spec.ts >> travel_change_order_detail >> E2E flow
- Location: travel_change_order_detail.expanded.spec.ts:1314:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#travel_change_order_action_confirm_change').first() to be visible

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
    - generic "详情" [ref=e15]:
      - navigation "breadcrumb" [ref=e17]:
        - list [ref=e18]:
          - listitem [ref=e19]:
            - generic [ref=e20]: 列表
          - listitem [ref=e21]:
            - img [ref=e22]
          - listitem [ref=e24]:
            - link "详情" [disabled] [ref=e25]
      - generic [ref=e27]:
        - generic [ref=e28]:
          - generic [ref=e29]:
            - paragraph [ref=e30]: TravelChangeOrder
            - paragraph [ref=e31]: 改签单,记录针对已有 TravelOrder 的改签请求、差价与审批状态;审批通过 overlay on Approvals 域
          - generic [ref=e32]: approved
        - generic [ref=e33]:
          - button "编辑" [ref=e34] [cursor=pointer]
          - button "提交改签申请,如 approval_mode=oa 则通过 integration 创建 ApprovalInstance" [ref=e35] [cursor=pointer]
          - button "complete" [ref=e36] [cursor=pointer]
          - button "删除" [ref=e37] [cursor=pointer]
      - generic [ref=e39]:
        - heading "基本信息" [level=3] [ref=e41]
        - generic [ref=e44]:
          - generic [ref=e45]:
            - paragraph [ref=e46]: 改签原因
            - paragraph [ref=e47]: UPDATED_1775257572250_h2bc1p_change_reason
          - generic [ref=e48]:
            - paragraph [ref=e49]: 差价
            - paragraph [ref=e50]: UPDATED_1775257572250_h2bc1p_price_difference
          - generic [ref=e51]:
            - paragraph [ref=e52]: 改签手续费
            - paragraph [ref=e53]: UPDATED_1775257572250_h2bc1p_change_fee
          - generic [ref=e54]:
            - paragraph [ref=e55]: status
            - paragraph [ref=e56]: approved
          - generic [ref=e57]:
            - paragraph [ref=e58]: 审批模式快照;none 表示跳过审批,self/oa 表示进入审批流
            - paragraph [ref=e59]: self
```

# Test source

```ts
  1381 |         await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
  1382 |         await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
  1383 |         await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
  1384 |       });
  1385 |       await test.step("CRUD：编辑记录", async () => {
  1386 |         await snapshotPreCreateIds(__ctx);
  1387 |         await ensureSeedRecord(page, __ctx);
  1388 |         await page.goto(resolveContractUrl(__ctx));
  1389 |         await syncRouteContext(page, __ctx);
  1390 |         await waitForLiveViewReady(page, 15000);
  1391 |       {
  1392 |         const loc = page.locator(`#edit_btn`).first();
  1393 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1394 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1395 |         const confirmText = await loc.getAttribute('data-confirm');
  1396 |         await loc.scrollIntoViewIfNeeded();
  1397 |         if (confirmText) {
  1398 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1399 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1400 |             .catch(() => null);
  1401 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1402 |           await dialogPromise;
  1403 |         } else {
  1404 |           await loc.click({ timeout: 15000 });
  1405 |         }
  1406 |         if (clickedId) {
  1407 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1408 |           refreshDataBindings(__ctx);
  1409 |         }
  1410 |         await waitForLiveViewReady(page, 15000);
  1411 |         await syncRouteContext(page, __ctx);
  1412 |       }
  1413 |       await expect(page.locator(`#travel_change_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
  1414 |       {
  1415 |         const loc = page.locator(`#travel_change_order_form_price_difference, [name='price_difference']`).first();
  1416 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1417 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_price_difference");
  1418 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1419 |         __ctx.form["price_difference"] = resolvedValue; refreshDataBindings(__ctx);
  1420 |       }
  1421 |       {
  1422 |         const loc = page.locator(`#travel_change_order_form_new_offer_id, [name='new_offer_id']`).first();
  1423 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1424 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_new_offer_id");
  1425 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1426 |         __ctx.form["new_offer_id"] = resolvedValue; refreshDataBindings(__ctx);
  1427 |       }
  1428 |       {
  1429 |         const loc = page.locator(`#travel_change_order_form_change_reason, [name='change_reason']`).first();
  1430 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1431 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_change_reason");
  1432 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1433 |         __ctx.form["change_reason"] = resolvedValue; refreshDataBindings(__ctx);
  1434 |       }
  1435 |       {
  1436 |         const loc = page.locator(`#travel_change_order_form_change_fee, [name='change_fee']`).first();
  1437 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1438 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_change_fee");
  1439 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1440 |         __ctx.form["change_fee"] = resolvedValue; refreshDataBindings(__ctx);
  1441 |       }
  1442 |       {
  1443 |         const loc = page.locator(`#travel_change_order_edit_form button[type="submit"], #travel_change_order_edit_form [phx-click="form_submit"]`).first();
  1444 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1445 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1446 |         const confirmText = await loc.getAttribute('data-confirm');
  1447 |         await loc.scrollIntoViewIfNeeded();
  1448 |         if (confirmText) {
  1449 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1450 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1451 |             .catch(() => null);
  1452 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1453 |           await dialogPromise;
  1454 |         } else {
  1455 |           await loc.click({ timeout: 15000 });
  1456 |         }
  1457 |         if (clickedId) {
  1458 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1459 |           refreshDataBindings(__ctx);
  1460 |         }
  1461 |         await waitForLiveViewReady(page, 15000);
  1462 |         await syncRouteContext(page, __ctx);
  1463 |       }
  1464 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1465 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1466 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1467 |       });
  1468 |       await test.step("状态转换：pending → approved（confirm_change）", async () => {
  1469 |       {
  1470 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_confirm_change}}");
  1471 |         const target = /^https?:\/\//.test(targetValue)
  1472 |           ? targetValue
  1473 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1474 |         await page.goto(target);
  1475 |       }
  1476 |       await waitForLiveViewReady(page, 15000);
  1477 |       await syncRouteContext(page, __ctx);
  1478 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1479 |       {
  1480 |         const loc = page.locator(`#travel_change_order_action_confirm_change`).first();
> 1481 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1482 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1483 |         const confirmText = await loc.getAttribute('data-confirm');
  1484 |         await loc.scrollIntoViewIfNeeded();
  1485 |         if (confirmText) {
  1486 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1487 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1488 |             .catch(() => null);
  1489 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1490 |           await dialogPromise;
  1491 |         } else {
  1492 |           await loc.click({ timeout: 15000 });
  1493 |         }
  1494 |         if (clickedId) {
  1495 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1496 |           __ctx["state_action_record_id_confirm_change"] = clickedId;
  1497 |           refreshDataBindings(__ctx);
  1498 |         }
  1499 |         if (!clickedId) {
  1500 |           __ctx["state_action_record_id_confirm_change"] = defaultRecordId(__ctx);
  1501 |         }
  1502 |         await waitForLiveViewReady(page, 15000);
  1503 |         await syncRouteContext(page, __ctx);
  1504 |       }
  1505 |         await runCaseWait(page, __ctx, "action_confirm_change", ["action_confirm_change"]);
  1506 |         await captureCreatedRecordId(__ctx, "state", ["action_confirm_change"]);
  1507 |         await runCaseVerification(page, __ctx, "action_confirm_change", "state", ["action_confirm_change"]);
  1508 |       });
  1509 |       await test.step("状态转换：pending → rejected（reject_change）", async () => {
  1510 |       {
  1511 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_reject_change}}");
  1512 |         const target = /^https?:\/\//.test(targetValue)
  1513 |           ? targetValue
  1514 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1515 |         await page.goto(target);
  1516 |       }
  1517 |       await waitForLiveViewReady(page, 15000);
  1518 |       await syncRouteContext(page, __ctx);
  1519 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1520 |       {
  1521 |         const loc = page.locator(`#travel_change_order_action_reject_change`).first();
  1522 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1523 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1524 |         const confirmText = await loc.getAttribute('data-confirm');
  1525 |         await loc.scrollIntoViewIfNeeded();
  1526 |         if (confirmText) {
  1527 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1528 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1529 |             .catch(() => null);
  1530 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1531 |           await dialogPromise;
  1532 |         } else {
  1533 |           await loc.click({ timeout: 15000 });
  1534 |         }
  1535 |         if (clickedId) {
  1536 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1537 |           __ctx["state_action_record_id_reject_change"] = clickedId;
  1538 |           refreshDataBindings(__ctx);
  1539 |         }
  1540 |         if (!clickedId) {
  1541 |           __ctx["state_action_record_id_reject_change"] = defaultRecordId(__ctx);
  1542 |         }
  1543 |         await waitForLiveViewReady(page, 15000);
  1544 |         await syncRouteContext(page, __ctx);
  1545 |       }
  1546 |         await runCaseWait(page, __ctx, "action_reject_change", ["action_reject_change"]);
  1547 |         await captureCreatedRecordId(__ctx, "state", ["action_reject_change"]);
  1548 |         await runCaseVerification(page, __ctx, "action_reject_change", "state", ["action_reject_change"]);
  1549 |       });
  1550 |       await test.step("状态转换：approved → completed（complete）", async () => {
  1551 |       {
  1552 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_complete}}");
  1553 |         const target = /^https?:\/\//.test(targetValue)
  1554 |           ? targetValue
  1555 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1556 |         await page.goto(target);
  1557 |       }
  1558 |       await waitForLiveViewReady(page, 15000);
  1559 |       await syncRouteContext(page, __ctx);
  1560 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1561 |       {
  1562 |         const loc = page.locator(`#travel_change_order_action_complete`).first();
  1563 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1564 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1565 |         const confirmText = await loc.getAttribute('data-confirm');
  1566 |         await loc.scrollIntoViewIfNeeded();
  1567 |         if (confirmText) {
  1568 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1569 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1570 |             .catch(() => null);
  1571 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1572 |           await dialogPromise;
  1573 |         } else {
  1574 |           await loc.click({ timeout: 15000 });
  1575 |         }
  1576 |         if (clickedId) {
  1577 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1578 |           __ctx["state_action_record_id_complete"] = clickedId;
  1579 |           refreshDataBindings(__ctx);
  1580 |         }
  1581 |         if (!clickedId) {
```