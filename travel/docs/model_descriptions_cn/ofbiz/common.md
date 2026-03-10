# 模型业务说明

- 版本：1.0
- 领域：Common
- 领域说明：从 OFBiz 导入的 Common 领域模型
- 实体数量：46

## 实体：数据来源（聚合根）

- 说明：Data Source
- 表名：data_sources

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 数据来源编号：文本
- 说明：文本

#### 关系
- 数据来源类型：多对一 -> 数据来源类型，外键 数据来源类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：数据来源类型（聚合根）

- 说明：Data Source Type
- 表名：data_source_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 数据来源类型编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：EmailTemplateSetting（聚合根）

- 说明：Email Template Setting
- 表名：email_template_settings

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- email_template_setting_id：文本
- 说明：文本
- 正文屏幕位置：文本，说明 if empty defaults to a screen based on the emailType
- if specified is used to generate XSL:FO that is transformed to a PDF via Apache FOP and attached to the email（xslfo_attach_screen_location）：文本
- 来源地址：文本
- 抄送地址：文本
- 密送地址：文本
- 主题：文本
- 内容类型：文本

#### 关系
- 枚举：多对一 -> 枚举，外键 邮箱类型

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：枚举（聚合根）

- 说明：Enumeration
- 表名：enumerations

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 枚举编号：文本
- 枚举编码：文本
- 序列编号：文本
- 说明：文本

#### 关系
- 枚举类型：多对一 -> 枚举类型，外键 枚举类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：枚举类型（聚合根）

- 说明：Enumeration Type
- 表名：enumeration_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 枚举类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 上级枚举类型：多对一 -> 枚举类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：CountryCapital（聚合根）

- 说明：Country Capital
- 表名：country_capitals

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- country_capital：文本

#### 关系
- 国家编码参考：多对一 -> 国家编码，外键 国家编码

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：国家编码（聚合根）

- 说明：ISO Country Code
- 表名：country_codes

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 国家编码：文本
- country_abbr：文本
- 国家单号：文本
- 国家名称：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：CountryTeleCode（聚合根）

- 说明：Telephone Country Code
- 表名：country_tele_codes

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- tele_code：文本

#### 关系
- 国家编码参考：多对一 -> 国家编码，外键 国家编码

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：国家地址格式（聚合根）

- 表名：country_address_formats

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 需求状态省编号：文本
- 需求邮政编码：布尔
- 邮政编码正则：文本
- 邮政编码扩展：布尔
- 需求邮政编码扩展：布尔
- 地址格式：文本

#### 关系
- 地理：多对一 -> 地理，外键 地理编号
- 地理关联类型：多对一 -> 地理关联类型，外键 地理关联类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：地理（聚合根）

- 说明：Geographic Boundary
- 表名：geos

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 地理编号：文本
- 地理名称：文本
- 地理编码：文本
- geo_sec_code：文本
- abbreviation：文本
- well_known_text：文本

#### 关系
- 地理类型：多对一 -> 地理类型，外键 地理类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：地理关联

- 说明：Geographic Boundary Association
- 表名：geo_assocs

### Schema（数据模型）

#### 关系
- 主要地理：多对一 -> 地理，外键 地理编号
- 关联地理：多对一 -> 地理，外键 地理编号
- 地理关联类型：多对一 -> 地理关联类型，外键 地理关联类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：地理关联类型（聚合根）

- 说明：Geographic Boundary Association
- 表名：geo_assoc_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 地理关联类型编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：地理坐标（聚合根）

- 说明：Geographic Location
- 表名：geo_points

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 地理点编号：文本
- 说明：文本
- 纬度：金额
- 经度：金额
- elevation：金额
- To enter any related information（information）：文本

#### 关系
- 数据来源：多对一 -> 数据来源，外键 数据来源编号
- 地理点类型枚举：多对一 -> 枚举，外键 地理点类型枚举编号
- elevation_uom：多对一 -> 单位，外键 elevation_uom_id

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：地理类型（聚合根）

- 说明：Geographic Boundary Type
- 表名：geo_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 地理类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 上级地理类型：多对一 -> 地理类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：KeywordThesaurus

- 表名：keyword_thesauruss

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 已录入关键词：文本
- 备选关键词：文本

#### 关系
- 关系枚举：多对一 -> 枚举，外键 关系枚举编号

#### 唯一约束
- 唯一约束 唯一已录入备选：已录入关键词、备选关键词

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：StandardLanguage（聚合根）

- 表名：standard_languages

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- standard_language_id：文本
- lang_code3t：文本
- lang_code3b：文本
- lang_code2：文本
- 语言名称：文本
- lang_family：文本
- lang_charset：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：自定义规则方法（聚合根）

- 说明：Custom Method
- 表名：custom_methods

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 自定义规则方法编号：文本
- 自定义规则方法名称：文本
- 说明：文本

#### 关系
- 自定义规则方法类型：多对一 -> 自定义规则方法类型，外键 自定义规则方法类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：自定义规则方法类型（聚合根）

- 说明：Custom Method Type
- 表名：custom_method_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 自定义规则方法类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 上级自定义规则方法类型：多对一 -> 自定义规则方法类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：备注数据（聚合根）

- 说明：Note Data
- 表名：note_datas

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 备注编号：文本
- 备注名称：文本
- 备注信息：文本
- 备注日期时间：日期时间

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：自定义规则时间期间（聚合根）

- 说明：Custom Time Period
- 表名：custom_time_periods

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 自定义规则时间期间编号：文本
- 期间编号：整数
- 期间名称：文本
- 来源日期：日期时间
- 至日期：日期时间
- 已关闭：布尔

#### 关系
- 上级自定义规则时间期间：多对一 -> 自定义规则时间期间，外键 上级期间编号
- 期间类型：多对一 -> 期间类型，外键 期间类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：期间类型（聚合根）

- 说明：Period Type
- 表名：period_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 期间类型编号：文本
- 说明：文本
- 期间长度：整数

#### 关系
- 单位：多对一 -> 单位，外键 单位编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：状态项（聚合根）

- 说明：Status
- 表名：status_items

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 状态编号：文本
- 状态编码：文本
- 序列编号：文本
- 说明：文本

#### 关系
- 状态类型：多对一 -> 状态类型，外键 状态类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：状态类型（聚合根）

- 说明：Status Type
- 表名：status_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 状态类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 上级状态类型：多对一 -> 状态类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：状态有效变更

- 说明：Status Valid Change
- 表名：status_valid_changes

### Schema（数据模型）

#### 字段
- 条件表达式：文本
- 转换名称：文本

#### 关系
- 主要状态项：多对一 -> 状态项，外键 状态编号
- 状态项：多对一 -> 状态项，外键 状态编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：单位（聚合根）

- 说明：Unit Of Measure
- 表名：uoms

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 单位编号：文本
- abbreviation：文本
- 数值编码：整数
- 说明：文本

#### 关系
- 单位类型参考：多对一 -> 单位类型，外键 单位类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：单位换算

- 说明：Unit Of Measure Conversion Type
- 表名：uom_conversions

### Schema（数据模型）

#### 字段
- 换算系数：浮点
- 金额缩放：整数
- 四舍五入模式：文本

#### 关系
- 主要单位：多对一 -> 单位，外键 单位编号
- conv_to_uom：多对一 -> 单位，外键 单位编号
- 单位自定义规则方法自定义规则方法：多对一 -> 自定义规则方法，外键 自定义规则方法编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：UomConversionDated

- 说明：Unit Of Measure Conversion Entity for those Units of Measure whose conversion values change over time (ie, currencies)
- 表名：uom_conversion_dateds

### Schema（数据模型）

#### 字段
- 来源日期：日期时间（主键）
- 至日期：日期时间
- 换算系数：浮点
- 金额缩放：整数
- 四舍五入模式：文本

#### 关系
- dated_main_uom：多对一 -> 单位，外键 单位编号
- dated_conv_to_uom：多对一 -> 单位，外键 单位编号
- 单位自定义规则方法自定义规则方法：多对一 -> 自定义规则方法，外键 自定义规则方法编号
- 用途枚举：多对一 -> 枚举，外键 用途枚举编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：单位分组

- 说明：Unit Of Measure Group
- 表名：uom_groups

### Schema（数据模型）

#### 字段
- 单位分组编号：文本（主键）

#### 关系
- 单位：多对一 -> 单位，外键 单位编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：单位类型（聚合根）

- 说明：Unit Of Measure Type
- 表名：uom_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 单位类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 上级单位类型：多对一 -> 单位类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：用户偏好

- 说明：The UserPreference entity contains one entry per preference per
          userLogin. User preferences are stored as key/value pairs (userPrefTypeId/userPrefValue).
          All values are stored as strings. Value strings can be converted to
          other data types by specifying a java data type in the userPrefDataType field.
- 表名：user_preferences

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 用户登录编号：文本
- 用户偏好类型编号：文本，说明 A unique identifier for this preference
- 用户偏好值：文本，说明 Contains the value of this preference
- 用户偏好数据类型：文本，说明 The java data type of this preference (empty = java.lang.String)

#### 关系
- 用户偏好分组类型：多对一 -> 用户偏好分组类型，外键 用户偏好分组类型编号

#### 唯一约束
- 唯一约束 唯一用户偏好：用户登录编号、用户偏好类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：用户偏好分组类型（聚合根）

- 说明：The UserPrefGroupType entity contains one entry per preference
          group type.
- 表名：user_pref_group_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 用户偏好分组类型编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：自定义规则屏幕（聚合根）

- 说明：Custom Screen
- 表名：custom_screens

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 自定义规则屏幕编号：文本
- 自定义规则屏幕名称：文本
- 自定义规则屏幕位置：文本
- 说明：文本

#### 关系
- 自定义规则屏幕类型：多对一 -> 自定义规则屏幕类型，外键 自定义规则屏幕类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：自定义规则屏幕类型（聚合根）

- 说明：Custom Screen Type
- 表名：custom_screen_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 自定义规则屏幕类型编号：文本
- 上级类型编号：文本
- 表：布尔
- 说明：文本

#### 关系
- 下级自定义规则屏幕类型：一对多 -> 自定义规则屏幕类型，外键 上级类型编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：视觉主题设置（聚合根）

- 说明：Groups toghether Visual Themes that can be used for one (or a set of) application.
- 表名：visual_theme_sets

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 视觉主题设置编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：视觉主题（聚合根）

- 说明：The VisualTheme entity contains one entry per visual theme.
- 表名：visual_themes

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 视觉主题编号：文本
- 说明：文本

#### 关系
- 视觉主题设置：多对一 -> 视觉主题设置，外键 视觉主题设置编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：视觉主题资源

- 说明：The VisualThemeResource entity contains visual theme
          resources. Each visual theme can have any number of resources.
- 表名：visual_theme_resources

### Schema（数据模型）

#### 字段
- 序列编号：文本（主键），说明 Controls the loading order of duplicate resource types
- 资源值：文本，说明 Contains the resource value

#### 关系
- 视觉主题：多对一 -> 视觉主题，外键 视觉主题编号
- 枚举：多对一 -> 枚举，外键 资源类型枚举编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：PortalPortlet（聚合根）

- 说明：Defines a Portlet to be used in Portals
- 表名：portal_portlets

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- portal_portlet_id：文本
- portlet_name：文本
- 屏幕名称：文本
- 屏幕位置：文本
- 编辑表单名称：文本
- 编辑表单位置：文本
- 说明：文本
- screenshot：文本
- 安全服务名称：文本，说明 The service named here is used to see if current user can see the portlet on the list of available portlets; the screen that the portlet calls should also call this service to check permission and not render; the service named here must implement the "permissionInterface" service just like services used for service permissions
- 安全主要操作：文本，说明 The main action which can be done with this portlet, possible values: CREATE UPDATE VIEW DELETE

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：PortletCategory（聚合根）

- 说明：Portlet Category
- 表名：portlet_categorys

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- portlet_category_id：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：PortletPortletCategory

- 说明：Defines Portlets included into Categories
- 表名：portlet_portlet_categorys

### Schema（数据模型）

#### 关系
- portal_portlet：多对一 -> PortalPortlet，外键 portal_portlet_id
- portlet_category：多对一 -> PortletCategory，外键 portlet_category_id

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：门户页面（聚合根）

- 说明：Defines a Portal Page
- 表名：portal_pages

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 门户页面编号：文本
- 门户页面名称：文本
- 说明：文本
- 所有者用户登录编号：文本
- 原始门户页面编号：文本，说明 The system portal page this page is derived from
- 序列编号：整数
- 安全分组编号：文本

#### 关系
- 上级门户页面：多对一 -> 门户页面，外键 上级门户页面编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：门户页面列

- 说明：Defines a Portal Page
- 表名：portal_page_columns

### Schema（数据模型）

#### 字段
- 列序列编号：文本（主键）
- column_width_pixels：整数
- 列宽度百分比：整数

#### 关系
- 门户页面：多对一 -> 门户页面，外键 门户页面编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：PortalPagePortlet

- 说明：Defines Portlets included into Portal Pages
- 表名：portal_page_portlets

### Schema（数据模型）

#### 字段
- Identify the portalPortlet instance in case more copy of the same portalPortlet are present in the same portalPage（portlet_seq_id）：文本（主键）
- 序列编号：整数

#### 关系
- 门户页面：多对一 -> 门户页面，外键 门户页面编号
- portal_portlet：多对一 -> PortalPortlet，外键 portal_portlet_id
- 门户页面列：多对一 -> 门户页面列，外键 列序列编号

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

## 实体：PortletAttribute

- 说明：Allows to set different attribute values for each instance of the same portlet
- 表名：portlet_attributes

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 门户页面编号：文本
- portlet_seq_id：文本
- 属性名称：文本
- 属性值：文本
- 属性说明：文本
- 属性类型：文本

#### 关系
- portal_portlet：多对一 -> PortalPortlet，外键 portal_portlet_id

#### 唯一约束
- 唯一约束 unique_portlet_attr：门户页面编号、portlet_seq_id、属性名称

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：SystemProperty

- 说明：Defines a System Property
- 表名：system_propertys

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 系统资源编号：文本
- system_property_id：文本
- system_property_value：文本
- 说明：文本

#### 唯一约束
- 唯一约束 unique_system_property：系统资源编号、system_property_id

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：电信方式类型（聚合根）

- 说明：Telecom Method Type
- 表名：telecom_method_types

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 电信方法类型编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

## 实体：电信网关配置（聚合根）

- 说明：Telecom Gateway Config
- 表名：telecom_gateway_configs

### Schema（数据模型）

#### 字段
- 编号：唯一标识（主键、自动生成）
- 电信网关配置编号：文本
- 说明：文本

### Conduct（行为声明）

#### 操作
- 查询
- 创建
- 更新
- 删除

#### 变更
- 在 创建 / 更新 / 删除 时，将 编号 设为 编号

