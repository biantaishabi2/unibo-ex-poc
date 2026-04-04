# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_refund_order_detail.expanded.spec.ts >> travel_refund_order_detail >> E2E flow
- Location: travel_refund_order_detail.expanded.spec.ts:1311:7

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
            - paragraph [ref=e47]: UPDATED_1775273270417_eutpqe_refund_reason
          - generic [ref=e48]:
            - paragraph [ref=e49]: 退票手续费
            - paragraph [ref=e50]: UPDATED_1775273270417_eutpqe_refund_fee
          - generic [ref=e51]:
            - paragraph [ref=e52]: 实退金额
            - paragraph [ref=e53]: UPDATED_1775273270417_eutpqe_refund_amount
          - generic [ref=e54]:
            - paragraph [ref=e55]: status
            - paragraph [ref=e56]: approved
          - generic [ref=e57]:
            - paragraph [ref=e58]: 审批模式快照;none 表示跳过审批,self/oa 表示进入审批流
            - paragraph [ref=e59]: self
```

# Test source

```ts
  1371 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1372 |           refreshDataBindings(__ctx);
  1373 |         }
  1374 |         await waitForLiveViewReady(page, 15000);
  1375 |         await syncRouteContext(page, __ctx);
  1376 |       }
  1377 |       await expect(page.locator(`#travel_refund_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).not.toBeVisible({ timeout: 15000 });
  1378 |         await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
  1379 |         await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
  1380 |         await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
  1381 |       });
  1382 |       await test.step("CRUD：编辑记录", async () => {
  1383 |         await snapshotPreCreateIds(__ctx);
  1384 |         await ensureSeedRecord(page, __ctx);
  1385 |         await page.goto(resolveContractUrl(__ctx));
  1386 |         await syncRouteContext(page, __ctx);
  1387 |         await waitForLiveViewReady(page, 15000);
  1388 |       {
  1389 |         const loc = page.locator(`#edit_btn`).first();
  1390 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1391 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1392 |         const confirmText = await loc.getAttribute('data-confirm');
  1393 |         await loc.scrollIntoViewIfNeeded();
  1394 |         if (confirmText) {
  1395 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1396 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1397 |             .catch(() => null);
  1398 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1399 |           await dialogPromise;
  1400 |         } else {
  1401 |           await loc.click({ timeout: 15000 });
  1402 |         }
  1403 |         if (clickedId) {
  1404 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1405 |           refreshDataBindings(__ctx);
  1406 |         }
  1407 |         await waitForLiveViewReady(page, 15000);
  1408 |         await syncRouteContext(page, __ctx);
  1409 |       }
  1410 |       await expect(page.locator(`#travel_refund_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
  1411 |       {
  1412 |         const loc = page.locator(`#travel_refund_order_form_refund_amount, [name='refund_amount']`).first();
  1413 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1414 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_amount");
  1415 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1416 |         __ctx.form["refund_amount"] = resolvedValue; refreshDataBindings(__ctx);
  1417 |       }
  1418 |       {
  1419 |         const loc = page.locator(`#travel_refund_order_form_refund_reason, [name='refund_reason']`).first();
  1420 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1421 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_reason");
  1422 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1423 |         __ctx.form["refund_reason"] = resolvedValue; refreshDataBindings(__ctx);
  1424 |       }
  1425 |       {
  1426 |         const loc = page.locator(`#travel_refund_order_form_refund_fee, [name='refund_fee']`).first();
  1427 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1428 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_refund_fee");
  1429 |         await loc.fill(resolvedValue, { timeout: 15000 });
  1430 |         __ctx.form["refund_fee"] = resolvedValue; refreshDataBindings(__ctx);
  1431 |       }
  1432 |       {
  1433 |         const loc = page.locator(`#travel_refund_order_edit_form button[type="submit"], #travel_refund_order_edit_form [phx-click="form_submit"]`).first();
  1434 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1435 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1436 |         const confirmText = await loc.getAttribute('data-confirm');
  1437 |         await loc.scrollIntoViewIfNeeded();
  1438 |         if (confirmText) {
  1439 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1440 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1441 |             .catch(() => null);
  1442 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1443 |           await dialogPromise;
  1444 |         } else {
  1445 |           await loc.click({ timeout: 15000 });
  1446 |         }
  1447 |         if (clickedId) {
  1448 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1449 |           refreshDataBindings(__ctx);
  1450 |         }
  1451 |         await waitForLiveViewReady(page, 15000);
  1452 |         await syncRouteContext(page, __ctx);
  1453 |       }
  1454 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  1455 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  1456 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  1457 |       });
  1458 |       await test.step("状态转换：pending → approved（confirm_refund）", async () => {
  1459 |       {
  1460 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_confirm_refund}}");
  1461 |         const target = /^https?:\/\//.test(targetValue)
  1462 |           ? targetValue
  1463 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1464 |         await page.goto(target);
  1465 |       }
  1466 |       await waitForLiveViewReady(page, 15000);
  1467 |       await syncRouteContext(page, __ctx);
  1468 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1469 |       {
  1470 |         const loc = page.locator(`#travel_refund_order_action_confirm_refund`).first();
> 1471 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  1472 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1473 |         const confirmText = await loc.getAttribute('data-confirm');
  1474 |         await loc.scrollIntoViewIfNeeded();
  1475 |         if (confirmText) {
  1476 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1477 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1478 |             .catch(() => null);
  1479 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1480 |           await dialogPromise;
  1481 |         } else {
  1482 |           await loc.click({ timeout: 15000 });
  1483 |         }
  1484 |         if (clickedId) {
  1485 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1486 |           __ctx["state_action_record_id_confirm_refund"] = clickedId;
  1487 |           refreshDataBindings(__ctx);
  1488 |         }
  1489 |         if (!clickedId) {
  1490 |           __ctx["state_action_record_id_confirm_refund"] = defaultRecordId(__ctx);
  1491 |         }
  1492 |         await waitForLiveViewReady(page, 15000);
  1493 |         await syncRouteContext(page, __ctx);
  1494 |       }
  1495 |         await runCaseWait(page, __ctx, "action_confirm_refund", ["action_confirm_refund"]);
  1496 |         await captureCreatedRecordId(__ctx, "state", ["action_confirm_refund"]);
  1497 |         await runCaseVerification(page, __ctx, "action_confirm_refund", "state", ["action_confirm_refund"]);
  1498 |       });
  1499 |       await test.step("状态转换：pending → rejected（reject_refund）", async () => {
  1500 |       {
  1501 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_reject_refund}}");
  1502 |         const target = /^https?:\/\//.test(targetValue)
  1503 |           ? targetValue
  1504 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1505 |         await page.goto(target);
  1506 |       }
  1507 |       await waitForLiveViewReady(page, 15000);
  1508 |       await syncRouteContext(page, __ctx);
  1509 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1510 |       {
  1511 |         const loc = page.locator(`#travel_refund_order_action_reject_refund`).first();
  1512 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1513 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1514 |         const confirmText = await loc.getAttribute('data-confirm');
  1515 |         await loc.scrollIntoViewIfNeeded();
  1516 |         if (confirmText) {
  1517 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1518 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1519 |             .catch(() => null);
  1520 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1521 |           await dialogPromise;
  1522 |         } else {
  1523 |           await loc.click({ timeout: 15000 });
  1524 |         }
  1525 |         if (clickedId) {
  1526 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1527 |           __ctx["state_action_record_id_reject_refund"] = clickedId;
  1528 |           refreshDataBindings(__ctx);
  1529 |         }
  1530 |         if (!clickedId) {
  1531 |           __ctx["state_action_record_id_reject_refund"] = defaultRecordId(__ctx);
  1532 |         }
  1533 |         await waitForLiveViewReady(page, 15000);
  1534 |         await syncRouteContext(page, __ctx);
  1535 |       }
  1536 |         await runCaseWait(page, __ctx, "action_reject_refund", ["action_reject_refund"]);
  1537 |         await captureCreatedRecordId(__ctx, "state", ["action_reject_refund"]);
  1538 |         await runCaseVerification(page, __ctx, "action_reject_refund", "state", ["action_reject_refund"]);
  1539 |       });
  1540 |       await test.step("状态转换：approved → refunded（refund）", async () => {
  1541 |       {
  1542 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_refund_order/{{state_action_record_id_refund}}");
  1543 |         const target = /^https?:\/\//.test(targetValue)
  1544 |           ? targetValue
  1545 |           : new URL(targetValue, "http://localhost:4100/").toString();
  1546 |         await page.goto(target);
  1547 |       }
  1548 |       await waitForLiveViewReady(page, 15000);
  1549 |       await syncRouteContext(page, __ctx);
  1550 |       await expect(page.locator(`#travel_refund_order_detail`)).toBeVisible({ timeout: 15000 });
  1551 |       {
  1552 |         const loc = page.locator(`#travel_refund_order_action_refund`).first();
  1553 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  1554 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  1555 |         const confirmText = await loc.getAttribute('data-confirm');
  1556 |         await loc.scrollIntoViewIfNeeded();
  1557 |         if (confirmText) {
  1558 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  1559 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  1560 |             .catch(() => null);
  1561 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  1562 |           await dialogPromise;
  1563 |         } else {
  1564 |           await loc.click({ timeout: 15000 });
  1565 |         }
  1566 |         if (clickedId) {
  1567 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  1568 |           __ctx["state_action_record_id_refund"] = clickedId;
  1569 |           refreshDataBindings(__ctx);
  1570 |         }
  1571 |         if (!clickedId) {
```