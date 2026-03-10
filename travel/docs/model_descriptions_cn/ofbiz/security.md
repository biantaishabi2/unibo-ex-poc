# 模型业务说明

- 版本：1.0
- 领域：安全
- 领域说明：从 OFBiz 导入的 Security 领域模型
- 实体数量：11

## 实体：X509IssuerProvision（聚合根）

- 说明：Valid issuer data for authentication of x.509 certificates
- 表名：x509_issuer_provisions

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- cert_provision_id：文本
- common_name：文本
- organizational_unit：文本
- 组织名称：文本
- city_locality：文本
- 状态省：文本
- 国家：文本
- 序列号单号：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：用户登录（聚合根）

- 说明：User Login
- 表名：user_logins

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 用户登录编号：文本
- 当前密码：文本
- 密码提示：文本
- 系统：布尔
- 启用：布尔
- has_logged_out：布尔
- 需求密码变更：布尔
- 最近币种单位：文本
- 最近区域：文本
- 最近时间区域：文本
- disabled_date_time：日期时间
- successive_failed_logins：整数
- 外部授权编号：文本，说明 For use with external authentication; the userLdapDn should be replaced with this
- The user's LDAP Distinguished Name - used for LDAP authentication（user_ldap_dn）：文本
- disabled_by：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：用户登录密码历史

- 说明：User Login Password History
- 表名：user_login_password_historys

### Schema（数据模型）

#### 字段
- 来源日期：日期时间（主键）
- 至日期：日期时间
- 当前密码：文本

#### 关系
- 用户登录：多对一 -> 用户登录，外键 用户登录编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：用户登录历史

- 说明：User Login History
- 表名：user_login_historys

### Schema（数据模型）

#### 字段
- 访问编号：文本
- 来源日期：日期时间（主键）
- 至日期：日期时间
- 密码已用：文本
- successful_login：布尔

#### 关系
- 用户登录：多对一 -> 用户登录，外键 用户登录编号
- 来源用户登录：多对一 -> 用户登录，外键 来源用户登录编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：用户登录会话（聚合根）

- 说明：User Login History
- 表名：user_login_sessions

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- saved_date：日期时间
- 会话数据：文本

#### 关系
- 用户登录：多对一 -> 用户登录，外键 用户登录编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：安全分组（聚合根）

- 说明：Security Component - Security Group
- 表名：security_groups

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 分组编号：文本
- 分组名称：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：安全分组权限

- 说明：Defines a permission available to a security group; there is no FK to SecurityPermission because we want to leave open the possibility of ad-hoc permissions, especially for the Entity Data Maintenance pages which have TONS of permissions
- 表名：security_group_permissions

### Schema（数据模型）

#### 字段
- 来源日期：日期时间（主键）
- 至日期：日期时间

#### 关系
- 安全分组：多对一 -> 安全分组，外键 分组编号
- 安全权限：多对一 -> 安全权限，外键 权限编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：安全权限（聚合根）

- 说明：Security Component - Security Permission
- 表名：security_permissions

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 权限编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：用户登录安全分组

- 说明：Maps a UserLogin to a security group
- 表名：user_login_security_groups

### Schema（数据模型）

#### 字段
- 来源日期：日期时间（主键）
- 至日期：日期时间

#### 关系
- 用户登录：多对一 -> 用户登录，外键 用户登录编号
- 安全分组：多对一 -> 安全分组，外键 分组编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：ProtectedView

- 说明：Defines views protected from data leakage
- 表名：protected_views

### Schema（数据模型）

#### 字段
- 视图名称编号：文本（主键），说明 name of view to protect from data theft
- number of hits before tarpitting a login for a view（max_hits）：整数
- period of time associated with maxHits (in seconds)（max_hits_duration）：整数
- period of time a login will not be able to acces  this view again (in seconds)（tarpit_duration）：整数

#### 关系
- 安全分组：多对一 -> 安全分组，外键 分组编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：TarpittedLoginView

- 说明：Login View couple currently tarpitted : any access to the view for the login is denied
- 表名：tarpitted_login_views

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 视图名称编号：文本，说明 name of view protected from data theft
- 用户登录编号：文本
- Date/Time at which the login will gain anew access to the view (in milliseconds from midnight, January 1, 1970 UTC , 0 meaning no tarpit to allow the admin to free a view and to keep history（tarpit_release_date_time）：整数

#### 唯一约束
- 唯一约束 unique_tarpit_login_view：视图名称编号、用户登录编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

