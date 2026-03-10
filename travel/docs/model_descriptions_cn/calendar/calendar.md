# 模型业务说明

- 版本：1.0
- 领域：日历
- 领域说明：日历管理领域模型，涵盖日程事件、会议安排、重复规则、参与者管理、工作日历模板与例外日期
- 实体数量：8

## 实体：日历（聚合根）

- 说明：日历容器，个人/团队/资源日历的统一管理单元
- 来源：基于 工作任务；来源域 ofbiz/workeffort；过滤条件 工作工作量类型编号=日历

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本（必填），说明 日历名称
- 说明：长文本，说明 日历描述
- 颜色：整数，默认值 0，说明 日历颜色索引
- 日历类型：枚举（必填），默认值 私有，可选值：私有 / 团队 / 资源，说明 日历类型（个人/团队/资源）
- 默认：布尔，默认值 否，说明 是否为默认日历
- 启用：布尔，默认值 是，说明 是否启用
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 所有者：多对一 -> 参与方，外键 所有者参与方编号，必填关系
- 活动：一对多 -> 日历活动，外键 日历编号

### Conduct（行为声明）

#### 操作
- 创建，可写字段：名称、说明、颜色、所有者参与方编号、日历类型、默认、启用
- 查询
- 更新，可写字段：名称、说明、颜色、日历类型、默认、启用
- 删除

#### 校验
- 创建时，名称 不能为空
- 创建时，所有者参与方编号 不能为空

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 工作流
- 流程：calendar_container_lifecycle_flow：创建 -> 更新 -> 删除（日历容器维护流程）

## 实体：日历活动（聚合根）

- 说明：日历事件（任务/会议），支持重复规则、全天事件、提醒、视频会议链接
- 来源：基于 工作任务；来源域 ofbiz/workeffort；过滤条件 工作工作量类型编号=任务、会议

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 标题：文本（必填），说明 事件标题（对齐 WorkEffort.work_effort_name）
- 说明：长文本，说明 事件描述（对齐 WorkEffort.description）
- 活动类型：枚举（必填），可选值：任务 / 会议，说明 事件类型（对齐 WorkEffort.work_effort_type_id，分界字段：Calendar 仅含 TASK/MEETING）
- 状态：枚举（必填），默认值 草稿，可选值：草稿 / tentative / 已确认 / 已取消，说明 事件状态（对齐 WorkEffort.current_status_id；P2-7：新增 tentative 状态）
- 用途：文本，说明 事件用途（对齐 WorkEffort.work_effort_purpose_type_id）
- 范围：枚举，默认值 内部，可选值：私有 / 公开 / 内部，说明 可见范围（对齐 WorkEffort.scope_enum_id）
- 优先级：整数，说明 优先级（对齐 WorkEffort.priority）
- 显示：枚举，默认值 忙碌，可选值：忙碌 / free / tentative / out_of_office，说明 显示方式（对齐 WorkEffort.show_as_enum_id）
- 位置：文本，说明 地点描述（对齐 WorkEffort.location_desc）
- 开始日期时间：日期时间（必填），说明 开始时间（对齐 WorkEffort.estimated_start_date）
- 结束日期时间：日期时间（必填），必须大于 开始日期时间（结束时间必须晚于开始时间），说明 结束时间（对齐 WorkEffort.estimated_completion_date）
- 实际开始：日期时间，说明 实际开始时间（对齐 WorkEffort.actual_start_date）
- 实际结束：日期时间，说明 实际结束时间（对齐 WorkEffort.actual_completion_date）
- 发送通知：布尔，默认值 是，说明 是否发送通知（对齐 WorkEffort.send_notification_email）
- iCal UID，用于日历同步（对齐 WorkEffort.universal_id）（ical_uid）：文本
- 来源参考号：文本，说明 外部来源引用（对齐 WorkEffort.source_reference_id）
- 重复周期规则：文本，说明 iCal RRULE 重复规则（如 FREQ=WEEKLY;BYDAY=MO）
- 全部天：布尔，默认值 否，说明 是否全天事件
- 提醒分钟：整数，说明 提前提醒分钟数
- 视频通话链接：文本，说明 视频会议链接
- 颜色：整数，默认值 0，说明 日历颜色索引
- 百分比完成：整数，说明 完成百分比（对齐 WorkEffort.percent_complete，仅任务类型使用）
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 日历：多对一 -> 日历，外键 日历编号
- 工作排班：多对一 -> 工作排班，外键 工作排班编号
- attendees：一对多 -> 参会者，外键 活动编号
- 上级活动：多对一 -> 日历活动，外键 上级活动编号
- 下级活动：一对多 -> 日历活动，外键 上级活动编号

#### 唯一约束
- 唯一约束 unique_ical_uid：ical_uid

### Conduct（行为声明）

#### 操作
- 创建，可写字段：标题、说明、活动类型、状态、用途、上级活动编号、日历编号、工作排班编号、范围、优先级、显示、位置、开始日期时间、结束日期时间、发送通知、重复周期规则、全部天、提醒分钟、视频通话链接、颜色、百分比完成
- 查询
- 更新，可写字段：标题、说明、状态、用途、范围、优先级、显示、位置、开始日期时间、结束日期时间、发送通知、重复周期规则、全部天、提醒分钟、视频通话链接、颜色、百分比完成、日历编号、工作排班编号
- 删除
- 确认（类型：更新），说明：确认事件
- 取消（类型：更新），说明：取消事件
- revert_to_draft（类型：更新），说明：退回草稿状态（P2-7：原 tentative action 语义修正为 revert_to_draft）
- mark_tentative（类型：更新），说明：标记为暂定状态（P2-7：新增，对应 status enum 中的 tentative）

#### 校验
- 创建时，标题 不能为空
- 创建时，开始日期时间 不能为空
- 创建时，结束日期时间 不能为空
- 创建时，活动类型 不能为空

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 计算
- 计算字段 生效时长：浮点，规则 计算生效时长(开始日期时间, 结束日期时间, 工作排班编号)

#### 事件
- 事件：确认 -> 日历.活动.已确认
- 事件：取消 -> 日历.活动.已取消
- 事件：更新 -> 日历.活动.rescheduled

#### 工作流
- 流程：calendar_event_lifecycle_flow：创建 -> 更新 -> 确认 -> 取消 -> revert_to_draft -> mark_tentative -> 删除（日历事件创建、修改与确认流程）

## 实体：参会者

- 说明：日历事件参与者，记录邀请和响应状态
- 来源：基于 工作任务参与方分配；来源域 ofbiz/workeffort

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 响应状态：枚举（必填），默认值 待处理，可选值：待处理 / 已接受 / 已拒绝 / tentative，说明 响应状态（对齐 WorkEffortPartyAssignment.status_id / availability_status_id）
- 组织者：布尔，默认值 否，说明 是否为组织者（对齐 WorkEffortPartyAssignment.role_type_id 判断）
- 角色：枚举，默认值 必填，可选值：组织者 / 必填 / 可选 / 资源，说明 参与角色（对齐 WorkEffortPartyAssignment.role_type_id）
- 必须回复：布尔，默认值 否，说明 是否强制回复（对齐 WorkEffortPartyAssignment.must_rsvp）
- 评论：长文本，说明 备注（对齐 WorkEffortPartyAssignment.comments）
- 响应时间（对齐 WorkEffortPartyAssignment.status_date_time）（responded_at）：日期时间
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 参与方：多对一 -> 参与方，外键 参与方编号
- 活动：多对一 -> 日历活动，外键 活动编号，必填关系

#### 唯一约束
- 唯一约束 唯一活动参与方：活动编号、参与方编号

### Conduct（行为声明）

#### 操作
- 邀请（类型：创建），说明：邀请参与者，可写字段：活动编号、参与方编号、角色、组织者、必须回复、评论
- 查询
- 更新响应（类型：更新），说明：更新响应状态，可写字段：响应状态、评论
- 移除（类型：删除），说明：移除参与者

#### 校验
- 邀请时，活动编号 不能为空
- 邀请时，参与方编号 不能为空

#### 变更
- 在 邀请 / 更新响应 / 移除 时，将 编号 设为 编号

#### 工作流
- 流程：attendee_response_flow：邀请 -> 更新响应 -> 移除（参与者邀请与响应流程）

## 实体：工作排班（聚合根）

- 说明：工作日历模板，定义工作时间规则（用于 HR/Manufacturing 排班）
- 来源：基于 技术数据日历；来源域 ofbiz/manufacturing

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本（必填），说明 日历名称（对齐 TechDataCalendar.calendar_id + description）
- 说明：长文本，说明 日历说明（对齐 TechDataCalendar.description）
- 启用：布尔，默认值 是，说明 是否启用
- 时区：文本，默认值 Asia/Shanghai，说明 时区
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 周模板：多对一 -> 周模板
- exceptions：一对多 -> 日历异常，外键 工作排班编号
- week_exceptions：一对多 -> 周异常，外键 工作排班编号
- 活动：一对多 -> 日历活动，外键 工作排班编号

### Conduct（行为声明）

#### 操作
- 创建，可写字段：名称、说明、启用、时区，参数：周模板编号：唯一标识
- 查询
- 更新，可写字段：名称、说明、启用、时区，参数：周模板编号：唯一标识
- 启用（类型：更新），说明：启用日历
- 停用（类型：更新），说明：停用日历
- 删除

#### 校验
- 创建时，名称 不能为空

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 工作流
- 流程：work_schedule_lifecycle_flow：创建 -> 更新 -> 启用 -> 停用 -> 删除（工作日历维护流程）

## 实体：周模板（聚合根）

- 说明：每周时间模板，定义每天的开始时间和工作容量
- 来源：基于 技术数据日历周；来源域 ofbiz/manufacturing

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本（必填），说明 周模板名称（对齐 TechDataCalendarWeek.calendar_week_id + description）
- 说明：长文本，说明 说明（对齐 TechDataCalendarWeek.description）
- 周一开始时间（对齐 TechDataCalendarWeek.monday_start_time）（monday_start）：文本
- 周一容量（对齐 TechDataCalendarWeek.monday_capacity）（monday_capacity）：浮点，默认值 0.0
- 周二开始时间（tuesday_start）：文本
- 周二容量（tuesday_capacity）：浮点，默认值 0.0
- 周三开始时间（wednesday_start）：文本
- 周三容量（wednesday_capacity）：浮点，默认值 0.0
- 周四开始时间（thursday_start）：文本
- 周四容量（thursday_capacity）：浮点，默认值 0.0
- 周五开始时间（friday_start）：文本
- 周五容量（friday_capacity）：浮点，默认值 0.0
- 周六开始时间（saturday_start）：文本
- 周六容量（saturday_capacity）：浮点，默认值 0.0
- 周日开始时间（sunday_start）：文本
- 周日容量（sunday_capacity）：浮点，默认值 0.0
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- work_schedules：一对多 -> 工作排班，外键 周模板编号

### Conduct（行为声明）

#### 操作
- 创建，可写字段：名称、说明、monday_start、monday_capacity、tuesday_start、tuesday_capacity、wednesday_start、wednesday_capacity、thursday_start、thursday_capacity、friday_start、friday_capacity、saturday_start、saturday_capacity、sunday_start、sunday_capacity
- 查询
- 更新，可写字段：名称、说明、monday_start、monday_capacity、tuesday_start、tuesday_capacity、wednesday_start、wednesday_capacity、thursday_start、thursday_capacity、friday_start、friday_capacity、saturday_start、saturday_capacity、sunday_start、sunday_capacity
- 删除

#### 校验
- 创建时，名称 不能为空

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

#### 工作流
- 流程：week_template_maintain_flow：创建 -> 更新 -> 删除（周模板维护）

## 实体：日历异常

- 说明：日历例外日期（节假日、特殊工作安排），覆盖常规周模板
- 来源：基于 技术数据日历排除日；来源域 ofbiz/manufacturing

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 异常日期：日期（必填），说明 例外日期（对齐 TechDataCalendarExcDay.exception_date_start_time）
- 异常类型：枚举（必填），可选值：假日 / 特别工作 / 半天 / 加班，说明 例外类型
- 说明：文本，说明 说明（如"劳动节"、"调休工作日"）（对齐 TechDataCalendarExcDay.description）
- 异常容量：浮点，说明 例外日容量（对齐 TechDataCalendarExcDay.exception_capacity）
- 开始时间：文本，说明 例外日开始时间
- 结束时间：文本，说明 例外日结束时间
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 工作排班：多对一 -> 工作排班，外键 工作排班编号，必填关系

#### 唯一约束
- 唯一约束 唯一排班日期：工作排班编号、异常日期

### Conduct（行为声明）

#### 操作
- 添加（类型：创建），说明：添加例外日期，可写字段：工作排班编号、异常日期、异常类型、说明、异常容量、开始时间、结束时间
- 查询
- 移除（类型：删除），说明：移除例外日期

#### 校验
- 添加时，工作排班编号 不能为空
- 添加时，异常日期 不能为空
- 添加时，异常类型 不能为空

#### 变更
- 在 添加 / 移除 时，将 编号 设为 编号

#### 工作流
- 流程：calendar_exception_manage_flow：添加 -> 移除（日历例外管理）

## 实体：周异常

- 说明：按周例外——在指定日期范围内用替代周模板覆盖默认周模板（对齐 OFBiz TechDataCalendarExcWeek）
- 来源：基于 技术数据日历排除周；来源域 ofbiz/manufacturing

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 开始日期：日期（必填），说明 周例外生效开始日期（对齐 TechDataCalendarExcWeek.exception_date_start_time）
- 结束日期：日期（必填），必须大于 开始日期（结束日期必须晚于开始日期），说明 周例外生效结束日期
- 说明：文本，说明 说明（如"春节调休周"、"项目冲刺周"）
- 创建时间：日期时间（自动生成）
- 更新时间：日期时间（自动生成）

#### 关系
- 工作排班：多对一 -> 工作排班，外键 工作排班编号，必填关系
- 覆盖周模板：多对一 -> 周模板

### Conduct（行为声明）

#### 操作
- 添加（类型：创建），说明：添加周例外，可写字段：工作排班编号、开始日期、结束日期、说明，参数：覆盖周模板编号：唯一标识（必填）
- 查询
- 移除（类型：删除），说明：移除周例外

#### 校验
- 添加时，工作排班编号 不能为空
- 添加时，开始日期 不能为空
- 添加时，结束日期 不能为空

#### 变更
- 在 添加 / 移除 时，将 编号 设为 编号

#### 工作流
- 流程：week_exception_manage_flow：添加 -> 移除（周例外管理）

## 实体：参与方

- 说明：跨域引用 Organization.Party（统一主体）

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 名称：文本

### Conduct（行为声明）

#### 操作
- 查询

