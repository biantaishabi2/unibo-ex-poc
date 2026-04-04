# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_change_order_detail.expanded.spec.ts >> travel_change_order_detail >> E2E flow
- Location: travel_change_order_detail.expanded.spec.ts:1315:7

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
            - paragraph [ref=e47]: UPDATED_1775278898448_7orx12_change_reason
          - generic [ref=e48]:
            - paragraph [ref=e49]: 差价
            - paragraph [ref=e50]: UPDATED_1775278898448_7orx12_price_difference
          - generic [ref=e51]:
            - paragraph [ref=e52]: 改签手续费
            - paragraph [ref=e53]: UPDATED_1775278898448_7orx12_change_fee
          - generic [ref=e54]:
            - paragraph [ref=e55]: status
            - paragraph [ref=e56]: approved
          - generic [ref=e57]:
            - paragraph [ref=e58]: 审批模式快照;none 表示跳过审批,self/oa 表示进入审批流
            - paragraph [ref=e59]: none
```

# Test source

```ts
  1382 |         await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
  1383 |         await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
  1384 |         await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
  1385 |       });
  1386 |       await test.step("CRUD：编辑记录", async () => {
  1387 |         await snapshotPreCreateIds(__ctx);
  1388 |         await ensureSeedRecord(page, __ctx);
  1389 |         await page.goto(resolveContractUrl(__ctx));
  1390 |         await syncRouteContext(page, __ctx);
  1391 |         await waitForLiveViewReady(page, 15000);
  1392 |       {
  1393 |         const loc = page.locator(`#edit_btn`).first();
  1394 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1395 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1396 |         const confirmText = await loc.getAttribute('data-confirm');
  1397 |         await loc.scrollIntoViewIfNeeded();
  1398 |         if (confirmText) {
  1399 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1400 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1401 |             .catch(() => null);
  1402 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1403 |           await dialogPromise;
  1404 |         } else {
  1405 |           await loc.click({ timeout: 15000 });
  1406 |         }
  1407 |         if (clickedId) {
  1408 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1409 |           refreshDataBindings(__ctx);
  1410 |         }
  1411 |         await waitForLiveViewReady(page, 15000);
  1412 |         await syncRouteContext(page, __ctx);
  1413 |       }
  1414 |       await expect(page.locator(`#travel_change_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
  1415 |       {
  1416 |         const loc = page.locator(`#travel_change_order_form_change_fee, [name='change_fee']`).first();
  1417 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1418 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_change_fee");
  1419 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1420 |         __ctx.form["change_fee"] = resolvedValue; refreshDataBindings(__ctx);
  1421 |       }
  1422 |       {
  1423 |         const loc = page.locator(`#travel_change_order_form_price_difference, [name='price_difference']`).first();
  1424 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1425 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_price_difference");
  1426 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1427 |         __ctx.form["price_difference"] = resolvedValue; refreshDataBindings(__ctx);
  1428 |       }
  1429 |       {
  1430 |         const loc = page.locator(`#travel_change_order_form_new_offer_id, [name='new_offer_id']`).first();
  1431 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1432 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_new_offer_id");
  1433 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1434 |         __ctx.form["new_offer_id"] = resolvedValue; refreshDataBindings(__ctx);
  1435 |       }
  1436 |       {
  1437 |         const loc = page.locator(`#travel_change_order_form_change_reason, [name='change_reason']`).first();
  1438 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1439 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_change_reason");
  1440 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1441 |         __ctx.form["change_reason"] = resolvedValue; refreshDataBindings(__ctx);
  1442 |       }
  1443 |       {
  1444 |         const loc = page.locator(`#travel_change_order_edit_form button[type="submit"], #travel_change_order_edit_form [phx-click="form_submit"]`).first();
  1445 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1446 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1447 |         const confirmText = await loc.getAttribute('data-confirm');
  1448 |         await loc.scrollIntoViewIfNeeded();
  1449 |         if (confirmText) {
  1450 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1451 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1452 |             .catch(() => null);
  1453 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1454 |           await dialogPromise;
  1455 |         } else {
  1456 |           await loc.click({ timeout: 15000 });
  1457 |         }
  1458 |         if (clickedId) {
  1459 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1460 |           refreshDataBindings(__ctx);
  1461 |         }
  1462 |         await waitForLiveViewReady(page, 15000);
  1463 |         await syncRouteContext(page, __ctx);
  1464 |       }
  1465 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1466 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1467 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1468 |       });
  1469 |       await test.step("状态转换：pending → approved（confirm_change）", async () => {
  1470 |       {
  1471 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_confirm_change}}");
  1472 |         const target = /^https?:\/\//.test(targetValue)
  1473 |           ? targetValue
  1474 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1475 |         await page.goto(target);
  1476 |       }
  1477 |       await waitForLiveViewReady(page, 15000);
  1478 |       await syncRouteContext(page, __ctx);
  1479 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1480 |       {
  1481 |         const loc = page.locator(`#travel_change_order_action_confirm_change`).first();
> 1482 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1483 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1484 |         const confirmText = await loc.getAttribute('data-confirm');
  1485 |         await loc.scrollIntoViewIfNeeded();
  1486 |         if (confirmText) {
  1487 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1488 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1489 |             .catch(() => null);
  1490 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1491 |           await dialogPromise;
  1492 |         } else {
  1493 |           await loc.click({ timeout: 15000 });
  1494 |         }
  1495 |         if (clickedId) {
  1496 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1497 |           __ctx["state_action_record_id_confirm_change"] = clickedId;
  1498 |           refreshDataBindings(__ctx);
  1499 |         }
  1500 |         if (!clickedId) {
  1501 |           __ctx["state_action_record_id_confirm_change"] = defaultRecordId(__ctx);
  1502 |         }
  1503 |         await waitForLiveViewReady(page, 15000);
  1504 |         await syncRouteContext(page, __ctx);
  1505 |       }
  1506 |         await runCaseWait(page, __ctx, "action_confirm_change", ["action_confirm_change"]);
  1507 |         await captureCreatedRecordId(__ctx, "state", ["action_confirm_change"]);
  1508 |         await runCaseVerification(page, __ctx, "action_confirm_change", "state", ["action_confirm_change"]);
  1509 |       });
  1510 |       await test.step("状态转换：pending → rejected（reject_change）", async () => {
  1511 |       {
  1512 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_reject_change}}");
  1513 |         const target = /^https?:\/\//.test(targetValue)
  1514 |           ? targetValue
  1515 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1516 |         await page.goto(target);
  1517 |       }
  1518 |       await waitForLiveViewReady(page, 15000);
  1519 |       await syncRouteContext(page, __ctx);
  1520 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1521 |       {
  1522 |         const loc = page.locator(`#travel_change_order_action_reject_change`).first();
  1523 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1524 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1525 |         const confirmText = await loc.getAttribute('data-confirm');
  1526 |         await loc.scrollIntoViewIfNeeded();
  1527 |         if (confirmText) {
  1528 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1529 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1530 |             .catch(() => null);
  1531 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1532 |           await dialogPromise;
  1533 |         } else {
  1534 |           await loc.click({ timeout: 15000 });
  1535 |         }
  1536 |         if (clickedId) {
  1537 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1538 |           __ctx["state_action_record_id_reject_change"] = clickedId;
  1539 |           refreshDataBindings(__ctx);
  1540 |         }
  1541 |         if (!clickedId) {
  1542 |           __ctx["state_action_record_id_reject_change"] = defaultRecordId(__ctx);
  1543 |         }
  1544 |         await waitForLiveViewReady(page, 15000);
  1545 |         await syncRouteContext(page, __ctx);
  1546 |       }
  1547 |         await runCaseWait(page, __ctx, "action_reject_change", ["action_reject_change"]);
  1548 |         await captureCreatedRecordId(__ctx, "state", ["action_reject_change"]);
  1549 |         await runCaseVerification(page, __ctx, "action_reject_change", "state", ["action_reject_change"]);
  1550 |       });
  1551 |       await test.step("状态转换：approved → completed（complete）", async () => {
  1552 |       {
  1553 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_change_order/{{state_action_record_id_complete}}");
  1554 |         const target = /^https?:\/\//.test(targetValue)
  1555 |           ? targetValue
  1556 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1557 |         await page.goto(target);
  1558 |       }
  1559 |       await waitForLiveViewReady(page, 15000);
  1560 |       await syncRouteContext(page, __ctx);
  1561 |       await expect(page.locator(`#travel_change_order_detail`)).toBeVisible({ timeout: 15000 });
  1562 |       {
  1563 |         const loc = page.locator(`#travel_change_order_action_complete`).first();
  1564 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1565 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1566 |         const confirmText = await loc.getAttribute('data-confirm');
  1567 |         await loc.scrollIntoViewIfNeeded();
  1568 |         if (confirmText) {
  1569 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1570 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1571 |             .catch(() => null);
  1572 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1573 |           await dialogPromise;
  1574 |         } else {
  1575 |           await loc.click({ timeout: 15000 });
  1576 |         }
  1577 |         if (clickedId) {
  1578 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1579 |           __ctx["state_action_record_id_complete"] = clickedId;
  1580 |           refreshDataBindings(__ctx);
  1581 |         }
  1582 |         if (!clickedId) {
```