# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_refund_order_detail.expanded.spec.ts >> travel_refund_order_detail >> E2E flow
- Location: travel_refund_order_detail.expanded.spec.ts:1310:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#travel_refund_order_action_confirm_refund').first() to be visible

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
            - paragraph [ref=e30]: TravelRefundOrder
            - paragraph [ref=e31]: 退票/退订单,记录针对已有 TravelOrder 的退票请求、手续费与退款状态;审批通过 overlay on Approvals 域
          - generic [ref=e32]: approved
        - generic [ref=e33]:
          - button "编辑" [ref=e34] [cursor=pointer]
          - button "提交退票申请,如 approval_mode=oa 则通过 integration 创建 ApprovalInstance" [ref=e35] [cursor=pointer]
          - button "refund" [ref=e36] [cursor=pointer]
          - button "删除" [ref=e37] [cursor=pointer]
      - generic [ref=e39]:
        - heading "基本信息" [level=3] [ref=e41]
        - generic [ref=e44]:
          - generic [ref=e45]:
            - paragraph [ref=e46]: 退票原因
            - paragraph [ref=e47]: UPDATED_1775257572312_rxtjfr_refund_reason
          - generic [ref=e48]:
            - paragraph [ref=e49]: 退票手续费
            - paragraph [ref=e50]: UPDATED_1775257572312_rxtjfr_refund_fee
          - generic [ref=e51]:
            - paragraph [ref=e52]: 实退金额
            - paragraph [ref=e53]: UPDATED_1775257572312_rxtjfr_refund_amount
          - generic [ref=e54]:
            - paragraph [ref=e55]: status
            - paragraph [ref=e56]: approved
          - generic [ref=e57]:
            - paragraph [ref=e58]: 审批模式快照;none 表示跳过审批,self/oa 表示进入审批流
            - paragraph [ref=e59]: self
```

# Test source

```ts
  1370 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1371 |           refreshDataBindings(__ctx);
  1372 |         }
  1373 |         await waitForLiveViewReady(page, 15000);
  1374 |         await syncRouteContext(page, __ctx);
  1375 |       }
  1376 |       await expect(page.locator(`#travel_refund_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).not.toBeVisible({ timeout: 15000 });
  1377 |         await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
  1378 |         await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
  1379 |         await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
  1380 |       });
  1381 |       await test.step("CRUD：编辑记录", async () => {
  1382 |         await snapshotPreCreateIds(__ctx);
  1383 |         await ensureSeedRecord(page, __ctx);
  1384 |         await page.goto(resolveContractUrl(__ctx));
  1385 |         await syncRouteContext(page, __ctx);
  1386 |         await waitForLiveViewReady(page, 15000);
  1387 |       {
  1388 |         const loc = page.locator(`#edit_btn`).first();
  1389 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1390 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1391 |         const confirmText = await loc.getAttribute('data-confirm');
  1392 |         await loc.scrollIntoViewIfNeeded();
  1393 |         if (confirmText) {
  1394 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1395 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1396 |             .catch(() => null);
  1397 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1398 |           await dialogPromise;
  1399 |         } else {
  1400 |           await loc.click({ timeout: 15000 });
  1401 |         }
  1402 |         if (clickedId) {
  1403 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1404 |           refreshDataBindings(__ctx);
  1405 |         }
  1406 |         await waitForLiveViewReady(page, 15000);
  1407 |         await syncRouteContext(page, __ctx);
  1408 |       }
  1409 |       await expect(page.locator(`#travel_refund_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
  1410 |       {
  1411 |         const loc = page.locator(`#travel_refund_order_form_refund_fee, [name='refund_fee']`).first();
  1412 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1413 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_fee");
  1414 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1415 |         __ctx.form["refund_fee"] = resolvedValue; refreshDataBindings(__ctx);
  1416 |       }
  1417 |       {
  1418 |         const loc = page.locator(`#travel_refund_order_form_refund_amount, [name='refund_amount']`).first();
  1419 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1420 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_amount");
  1421 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1422 |         __ctx.form["refund_amount"] = resolvedValue; refreshDataBindings(__ctx);
  1423 |       }
  1424 |       {
  1425 |         const loc = page.locator(`#travel_refund_order_form_refund_reason, [name='refund_reason']`).first();
  1426 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1427 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_reason");
  1428 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1429 |         __ctx.form["refund_reason"] = resolvedValue; refreshDataBindings(__ctx);
  1430 |       }
  1431 |       {
  1432 |         const loc = page.locator(`#travel_refund_order_edit_form button[type="submit"], #travel_refund_order_edit_form [phx-click="form_submit"]`).first();
  1433 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1434 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1435 |         const confirmText = await loc.getAttribute('data-confirm');
  1436 |         await loc.scrollIntoViewIfNeeded();
  1437 |         if (confirmText) {
  1438 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1439 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1440 |             .catch(() => null);
  1441 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1442 |           await dialogPromise;
  1443 |         } else {
  1444 |           await loc.click({ timeout: 15000 });
  1445 |         }
  1446 |         if (clickedId) {
  1447 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1448 |           refreshDataBindings(__ctx);
  1449 |         }
  1450 |         await waitForLiveViewReady(page, 15000);
  1451 |         await syncRouteContext(page, __ctx);
  1452 |       }
  1453 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1454 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1455 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1456 |       });
  1457 |       await test.step("状态转换：pending → approved（confirm_refund）", async () => {
  1458 |       {
  1459 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_confirm_refund}}");
  1460 |         const target = /^https?:\/\//.test(targetValue)
  1461 |           ? targetValue
  1462 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1463 |         await page.goto(target);
  1464 |       }
  1465 |       await waitForLiveViewReady(page, 15000);
  1466 |       await syncRouteContext(page, __ctx);
  1467 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1468 |       {
  1469 |         const loc = page.locator(`#travel_refund_order_action_confirm_refund`).first();
> 1470 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1471 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1472 |         const confirmText = await loc.getAttribute('data-confirm');
  1473 |         await loc.scrollIntoViewIfNeeded();
  1474 |         if (confirmText) {
  1475 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1476 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1477 |             .catch(() => null);
  1478 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1479 |           await dialogPromise;
  1480 |         } else {
  1481 |           await loc.click({ timeout: 15000 });
  1482 |         }
  1483 |         if (clickedId) {
  1484 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1485 |           __ctx["state_action_record_id_confirm_refund"] = clickedId;
  1486 |           refreshDataBindings(__ctx);
  1487 |         }
  1488 |         if (!clickedId) {
  1489 |           __ctx["state_action_record_id_confirm_refund"] = defaultRecordId(__ctx);
  1490 |         }
  1491 |         await waitForLiveViewReady(page, 15000);
  1492 |         await syncRouteContext(page, __ctx);
  1493 |       }
  1494 |         await runCaseWait(page, __ctx, "action_confirm_refund", ["action_confirm_refund"]);
  1495 |         await captureCreatedRecordId(__ctx, "state", ["action_confirm_refund"]);
  1496 |         await runCaseVerification(page, __ctx, "action_confirm_refund", "state", ["action_confirm_refund"]);
  1497 |       });
  1498 |       await test.step("状态转换：pending → rejected（reject_refund）", async () => {
  1499 |       {
  1500 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_reject_refund}}");
  1501 |         const target = /^https?:\/\//.test(targetValue)
  1502 |           ? targetValue
  1503 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1504 |         await page.goto(target);
  1505 |       }
  1506 |       await waitForLiveViewReady(page, 15000);
  1507 |       await syncRouteContext(page, __ctx);
  1508 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1509 |       {
  1510 |         const loc = page.locator(`#travel_refund_order_action_reject_refund`).first();
  1511 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1512 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1513 |         const confirmText = await loc.getAttribute('data-confirm');
  1514 |         await loc.scrollIntoViewIfNeeded();
  1515 |         if (confirmText) {
  1516 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1517 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1518 |             .catch(() => null);
  1519 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1520 |           await dialogPromise;
  1521 |         } else {
  1522 |           await loc.click({ timeout: 15000 });
  1523 |         }
  1524 |         if (clickedId) {
  1525 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1526 |           __ctx["state_action_record_id_reject_refund"] = clickedId;
  1527 |           refreshDataBindings(__ctx);
  1528 |         }
  1529 |         if (!clickedId) {
  1530 |           __ctx["state_action_record_id_reject_refund"] = defaultRecordId(__ctx);
  1531 |         }
  1532 |         await waitForLiveViewReady(page, 15000);
  1533 |         await syncRouteContext(page, __ctx);
  1534 |       }
  1535 |         await runCaseWait(page, __ctx, "action_reject_refund", ["action_reject_refund"]);
  1536 |         await captureCreatedRecordId(__ctx, "state", ["action_reject_refund"]);
  1537 |         await runCaseVerification(page, __ctx, "action_reject_refund", "state", ["action_reject_refund"]);
  1538 |       });
  1539 |       await test.step("状态转换：approved → refunded（refund）", async () => {
  1540 |       {
  1541 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_refund}}");
  1542 |         const target = /^https?:\/\//.test(targetValue)
  1543 |           ? targetValue
  1544 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1545 |         await page.goto(target);
  1546 |       }
  1547 |       await waitForLiveViewReady(page, 15000);
  1548 |       await syncRouteContext(page, __ctx);
  1549 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1550 |       {
  1551 |         const loc = page.locator(`#travel_refund_order_action_refund`).first();
  1552 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1553 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1554 |         const confirmText = await loc.getAttribute('data-confirm');
  1555 |         await loc.scrollIntoViewIfNeeded();
  1556 |         if (confirmText) {
  1557 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1558 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1559 |             .catch(() => null);
  1560 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1561 |           await dialogPromise;
  1562 |         } else {
  1563 |           await loc.click({ timeout: 15000 });
  1564 |         }
  1565 |         if (clickedId) {
  1566 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1567 |           __ctx["state_action_record_id_refund"] = clickedId;
  1568 |           refreshDataBindings(__ctx);
  1569 |         }
  1570 |         if (!clickedId) {
```