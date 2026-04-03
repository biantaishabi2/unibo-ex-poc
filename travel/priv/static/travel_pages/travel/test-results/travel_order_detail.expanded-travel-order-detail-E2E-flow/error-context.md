# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: travel_order_detail.expanded.spec.ts >> travel_order_detail >> E2E flow
- Location: travel_order_detail.expanded.spec.ts:2223:7

# Error details

```
TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
Call log:
  - waiting for locator('#travel_order_action_confirm_quote').first() to be visible

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
        - generic [ref=e29]:
          - paragraph [ref=e30]: TravelOrder
          - paragraph [ref=e31]: 统一酒旅订单,承接 hotel、flight、vacation、train 四类商品的下单和状态流转;通过跨域引用关联 Sales::Customer 和 Payment::Payment
        - generic [ref=e33]:
          - button "编辑" [ref=e34] [cursor=pointer]
          - button "request_change" [ref=e35] [cursor=pointer]
          - button "confirm_change" [ref=e36] [cursor=pointer]
          - button "删除" [ref=e37] [cursor=pointer]
      - generic [ref=e39]:
        - heading "基本信息" [level=3] [ref=e41]
        - generic [ref=e44]:
          - generic [ref=e45]:
            - paragraph [ref=e46]: 订单号
            - paragraph
          - generic [ref=e47]:
            - paragraph [ref=e48]: 商品类型
            - paragraph
          - generic [ref=e49]:
            - paragraph [ref=e50]: train 订单预订模式
            - paragraph
          - generic [ref=e51]:
            - paragraph [ref=e52]: contact_name
            - paragraph
          - generic [ref=e53]:
            - paragraph [ref=e54]: contact_phone
            - paragraph
          - generic [ref=e55]:
            - paragraph [ref=e56]: 出行人数量
            - paragraph
          - generic [ref=e57]:
            - paragraph [ref=e58]: 订单总金额
            - paragraph
          - generic [ref=e59]:
            - paragraph [ref=e60]: 计划使用的积分数量
            - paragraph
          - generic [ref=e61]:
            - paragraph [ref=e62]: 积分抵现金额
            - paragraph
          - generic [ref=e63]:
            - paragraph [ref=e64]: 宿主 quote 返回的推荐支付方式
            - paragraph
          - generic [ref=e65]:
            - paragraph [ref=e66]: currency
            - paragraph
          - generic [ref=e67]:
            - paragraph [ref=e68]: status
            - paragraph
          - generic [ref=e69]:
            - paragraph [ref=e70]: change_status
            - paragraph
          - generic [ref=e71]:
            - paragraph [ref=e72]: waitlist_status
            - paragraph
          - generic [ref=e73]:
            - paragraph [ref=e74]: 改签链路引用的原订单号或原票号
            - paragraph
          - generic [ref=e75]:
            - paragraph [ref=e76]: 乘车人信息快照
            - paragraph
          - generic [ref=e77]:
            - paragraph [ref=e78]: 选座与席别偏好快照
            - paragraph
          - generic [ref=e79]:
            - paragraph [ref=e80]: 供应商订单号
            - paragraph
          - generic [ref=e81]:
            - paragraph [ref=e82]: 宿主支付侧外部支付流水号
            - paragraph
```

# Test source

```ts
  2297 |         await page.goto(resolveContractUrl(__ctx));
  2298 |         await syncRouteContext(page, __ctx);
  2299 |         await waitForLiveViewReady(page, 15000);
  2300 |       {
  2301 |         const loc = page.locator(`#edit_btn`).first();
  2302 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2303 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  2304 |         const confirmText = await loc.getAttribute('data-confirm');
  2305 |         await loc.scrollIntoViewIfNeeded();
  2306 |         if (confirmText) {
  2307 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  2308 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  2309 |             .catch(() => null);
  2310 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  2311 |           await dialogPromise;
  2312 |         } else {
  2313 |           await loc.click({ timeout: 15000 });
  2314 |         }
  2315 |         if (clickedId) {
  2316 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  2317 |           refreshDataBindings(__ctx);
  2318 |         }
  2319 |         await waitForLiveViewReady(page, 15000);
  2320 |         await syncRouteContext(page, __ctx);
  2321 |       }
  2322 |       await expect(page.locator(`#travel_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
  2323 |       {
  2324 |         const loc = page.locator(`#travel_order_form_contact_name, [name='contact_name']`).first();
  2325 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2326 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_contact_name");
  2327 |         await loc.fill(resolvedValue, { timeout: 15000 });
  2328 |         __ctx.form["contact_name"] = resolvedValue; refreshDataBindings(__ctx);
  2329 |       }
  2330 |       {
  2331 |         const loc = page.locator(`#travel_order_form_traveler_count, [name='traveler_count']`).first();
  2332 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2333 |         const resolvedValue = resolveTemplateString(__ctx, "2");
  2334 |         await loc.fill(resolvedValue, { timeout: 15000 });
  2335 |         __ctx.form["traveler_count"] = resolvedValue; refreshDataBindings(__ctx);
  2336 |       }
  2337 |       {
  2338 |         const loc = page.locator(`#travel_order_form_contact_phone, [name='contact_phone']`).first();
  2339 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2340 |         const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_contact_phone");
  2341 |         await loc.fill(resolvedValue, { timeout: 15000 });
  2342 |         __ctx.form["contact_phone"] = resolvedValue; refreshDataBindings(__ctx);
  2343 |       }
  2344 |       {
  2345 |         const loc = page.locator(`#travel_order_form_seat_selection_snapshot, [name='seat_selection_snapshot']`).first();
  2346 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2347 |         const resolvedValue = resolveTemplateString(__ctx, "{\"updated\":true}");
  2348 |         await loc.fill(resolvedValue, { timeout: 15000 });
  2349 |         __ctx.form["seat_selection_snapshot"] = resolvedValue; refreshDataBindings(__ctx);
  2350 |       }
  2351 |       {
  2352 |         const loc = page.locator(`#travel_order_form_ticket_passenger_infos, [name='ticket_passenger_infos']`).first();
  2353 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2354 |         const resolvedValue = resolveTemplateString(__ctx, "{\"updated\":true}");
  2355 |         await loc.fill(resolvedValue, { timeout: 15000 });
  2356 |         __ctx.form["ticket_passenger_infos"] = resolvedValue; refreshDataBindings(__ctx);
  2357 |       }
  2358 |       {
  2359 |         const loc = page.locator(`#travel_order_edit_form button[type="submit"], #travel_order_edit_form [phx-click="form_submit"]`).first();
  2360 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2361 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  2362 |         const confirmText = await loc.getAttribute('data-confirm');
  2363 |         await loc.scrollIntoViewIfNeeded();
  2364 |         if (confirmText) {
  2365 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  2366 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  2367 |             .catch(() => null);
  2368 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  2369 |           await dialogPromise;
  2370 |         } else {
  2371 |           await loc.click({ timeout: 15000 });
  2372 |         }
  2373 |         if (clickedId) {
  2374 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  2375 |           refreshDataBindings(__ctx);
  2376 |         }
  2377 |         await waitForLiveViewReady(page, 15000);
  2378 |         await syncRouteContext(page, __ctx);
  2379 |       }
  2380 |         await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
  2381 |         await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
  2382 |         await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
  2383 |       });
  2384 |       await test.step("状态转换：draft → quoted（confirm_quote）", async () => {
  2385 |       {
  2386 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_confirm_quote}}");
  2387 |         const target = /^https?:\/\//.test(targetValue)
  2388 |           ? targetValue
  2389 |           : new URL(targetValue, "http://localhost:4100/").toString();
  2390 |         await page.goto(target);
  2391 |       }
  2392 |       await waitForLiveViewReady(page, 15000);
  2393 |       await syncRouteContext(page, __ctx);
  2394 |       await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
  2395 |       {
  2396 |         const loc = page.locator(`#travel_order_action_confirm_quote`).first();
> 2397 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
       |                   ^ TimeoutError: locator.waitFor: Timeout 15000ms exceeded.
  2398 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  2399 |         const confirmText = await loc.getAttribute('data-confirm');
  2400 |         await loc.scrollIntoViewIfNeeded();
  2401 |         if (confirmText) {
  2402 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  2403 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  2404 |             .catch(() => null);
  2405 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  2406 |           await dialogPromise;
  2407 |         } else {
  2408 |           await loc.click({ timeout: 15000 });
  2409 |         }
  2410 |         if (clickedId) {
  2411 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  2412 |           __ctx["state_action_record_id_confirm_quote"] = clickedId;
  2413 |           refreshDataBindings(__ctx);
  2414 |         }
  2415 |         if (!clickedId) {
  2416 |           __ctx["state_action_record_id_confirm_quote"] = defaultRecordId(__ctx);
  2417 |         }
  2418 |         await waitForLiveViewReady(page, 15000);
  2419 |         await syncRouteContext(page, __ctx);
  2420 |       }
  2421 |         await runCaseWait(page, __ctx, "action_confirm_quote", ["action_confirm_quote"]);
  2422 |         await captureCreatedRecordId(__ctx, "state", ["action_confirm_quote"]);
  2423 |         await runCaseVerification(page, __ctx, "action_confirm_quote", "state", ["action_confirm_quote"]);
  2424 |       });
  2425 |       await test.step("状态转换：quoted → submitted（submit_order）", async () => {
  2426 |       {
  2427 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_submit_order}}");
  2428 |         const target = /^https?:\/\//.test(targetValue)
  2429 |           ? targetValue
  2430 |           : new URL(targetValue, "http://localhost:4100/").toString();
  2431 |         await page.goto(target);
  2432 |       }
  2433 |       await waitForLiveViewReady(page, 15000);
  2434 |       await syncRouteContext(page, __ctx);
  2435 |       await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
  2436 |       {
  2437 |         const loc = page.locator(`#travel_order_action_submit_order`).first();
  2438 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2439 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  2440 |         const confirmText = await loc.getAttribute('data-confirm');
  2441 |         await loc.scrollIntoViewIfNeeded();
  2442 |         if (confirmText) {
  2443 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  2444 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  2445 |             .catch(() => null);
  2446 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  2447 |           await dialogPromise;
  2448 |         } else {
  2449 |           await loc.click({ timeout: 15000 });
  2450 |         }
  2451 |         if (clickedId) {
  2452 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  2453 |           __ctx["state_action_record_id_submit_order"] = clickedId;
  2454 |           refreshDataBindings(__ctx);
  2455 |         }
  2456 |         if (!clickedId) {
  2457 |           __ctx["state_action_record_id_submit_order"] = defaultRecordId(__ctx);
  2458 |         }
  2459 |         await waitForLiveViewReady(page, 15000);
  2460 |         await syncRouteContext(page, __ctx);
  2461 |       }
  2462 |         await runCaseWait(page, __ctx, "action_submit_order", ["action_submit_order"]);
  2463 |         await captureCreatedRecordId(__ctx, "state", ["action_submit_order"]);
  2464 |         await runCaseVerification(page, __ctx, "action_submit_order", "state", ["action_submit_order"]);
  2465 |       });
  2466 |       await test.step("状态转换：quoted → submitted（submit_waitlist）", async () => {
  2467 |       {
  2468 |         const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_submit_waitlist}}");
  2469 |         const target = /^https?:\/\//.test(targetValue)
  2470 |           ? targetValue
  2471 |           : new URL(targetValue, "http://localhost:4100/").toString();
  2472 |         await page.goto(target);
  2473 |       }
  2474 |       await waitForLiveViewReady(page, 15000);
  2475 |       await syncRouteContext(page, __ctx);
  2476 |       await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
  2477 |       {
  2478 |         const loc = page.locator(`#travel_order_action_submit_waitlist`).first();
  2479 |         await loc.waitFor({ state: 'visible', timeout: 15000 });
  2480 |         const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
  2481 |         const confirmText = await loc.getAttribute('data-confirm');
  2482 |         await loc.scrollIntoViewIfNeeded();
  2483 |         if (confirmText) {
  2484 |           const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
  2485 |             .then(async (dialog) => { await dialog.accept(); return dialog; })
  2486 |             .catch(() => null);
  2487 |           await loc.click({ timeout: 15000, noWaitAfter: true });
  2488 |           await dialogPromise;
  2489 |         } else {
  2490 |           await loc.click({ timeout: 15000 });
  2491 |         }
  2492 |         if (clickedId) {
  2493 |           __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
  2494 |           __ctx["state_action_record_id_submit_waitlist"] = clickedId;
  2495 |           refreshDataBindings(__ctx);
  2496 |         }
  2497 |         if (!clickedId) {
```