# 前端页面截图验证现状（2026-03-23）

## Scheduling 域（21 页）

### 正常渲染（14 页）

| 页面 | 类型 | 数据 |
|------|------|------|
| scheduling_period_list | list | ✅ 5 条排班周期数据 |
| scheduling_constraint_list | list | ✅ 约束规则数据（hard/soft+权重） |
| scheduling_constraint_detail | detail | ✅ "每班至少1名带班护士"表单 |
| scheduling_constraint_detail_new | detail | ✅ 空表单 |
| shift_type_list | list | ✅ day/evening/night 数据 |
| shift_type_detail | detail | ✅ "小夜班"数据 |
| shift_type_detail_new | detail | ✅ 空表单 |
| calendar_adjustment | custom | ✅ 日历调班（上下周+统计） |
| publish_preview | custom | ✅ 发布预览（变更对比） |
| requirement_matrix | custom | ✅ 需求矩阵（3 班次） |
| solver_result | custom | ✅ 排班结果（约束违反明细） |
| shift_swap_list | list | ✅ 偏好数据+分页 |
| my_schedule | calendar | ✅ 空状态（预期，无排班数据） |
| team_schedule | calendar | ✅ 空状态（预期） |

### 有问题（7 页）

| 页面 | 错误 | 根因 | Issue |
|------|------|------|-------|
| scheduling_period_detail | KeyError: :status not found in: nil | page_host_live 动态编译缓存 | #1646 |
| scheduling_period_detail_new | EEx 未解析（`<%= ver.version_no %>`） | 同 #1646（旧 beam 缓存） | #1646 |
| schedule_notification | 空状态 | 正常（SchedulingPeriod 无通知数据） | — |
| schedule_overview | 渲染正常但数据为 mock | 正常（overview 页面用 mock） | — |
| shift_swap_request | contract_missing | __load__ 对纯创建表单返回 "get" | #1645 |
| shift_preference_form | contract_missing | 同 #1645 | #1645 |
| leave_request | contract_missing | 同 #1645 | #1645 |

### 汇总

- ✅ 正常：14/21（67%）
- ❌ contract_missing：3/21（#1645）
- ❌ KeyError/缓存：2/21（#1646）
- ⚠️ 空状态/mock（预期行为）：2/21

---

## Travel 域（84 页）

### 正常渲染的页面类型

- **Admin list 页面**（~20 个）：travel_order_list, travel_airline_list, flight_offer_list, hotel_offer_list 等 — 表头+筛选+空状态
- **Admin detail 页面**（~15 个）：scheduling_constraint_detail 类型的表单页 — 字段标签正常
- **Admin detail_new 页面**（~15 个）：空表单骨架

### 有问题的页面

| 类型 | 数量 | 错误 | Issue |
|------|------|------|-------|
| User form 页面 | ~5 | contract_missing | #1645 |
| Detail 页有嵌套关联 | ~3 | KeyError（动态编译缓存） | #1646 |
| 无 seed 数据的页面 | ~15 | 空状态"暂无内容" | 需灌 seed |

### 汇总

- ✅ 正常渲染：~60/84（71%）
- ❌ contract_missing：~5（#1645）
- ❌ KeyError/缓存：~3（#1646）
- ⚠️ 空状态（缺 seed 数据）：~15

---

## 待修 Issue

| Issue | 问题 | 影响范围 |
|-------|------|---------|
| **#1645** | stitch_backend __load__ 对纯创建表单应跳过查询 | Scheduling 3 页 + Travel ~5 页 |
| **#1646** | page_host_live 动态编译 HEEx 缓存/加载问题 | Scheduling 2 页 + Travel ~3 页 |

修完后重跑 compile-frontend + 截图验证。
