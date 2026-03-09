defmodule UniboExPoc.Generated.BddDomainRegistry do
  @moduledoc "自动生成的 BDD 域注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "BDD 域键 → Ash Domain 模块映射"
  def domain_map do
    %{
      "ACCOUNTING" => UniboExPoc.Accounting,
      "DELIVERY" => UniboExPoc.Delivery,
      "ECOMMERCE" => UniboExPoc.Ecommerce,
      "PAYMENT" => UniboExPoc.Payment,
      "SALES" => UniboExPoc.Sales,
      "TRAVEL" => UniboExPoc.Travel,
      "OFBIZ_ACCOUNTING" => UniboExPoc.Ofbiz.Accounting,
      "OFBIZ_COMMON" => UniboExPoc.Ofbiz.Common,
      "OFBIZ_ORDER" => UniboExPoc.Ofbiz.Order,
      "OFBIZ_PARTY" => UniboExPoc.Ofbiz.Party,
      "OFBIZ_PRODUCT" => UniboExPoc.Ofbiz.Product,
      "OFBIZ_SHIPMENT" => UniboExPoc.Ofbiz.Shipment,
    }
  end

  @doc "BDD 域键 → 目录名映射"
  def module_dirs do
    %{
      "ACCOUNTING" => "accounting",
      "ANALYTIC" => "analytic",
      "APPROVALS" => "approvals",
      "BARCODE" => "barcode",
      "BDD" => "bdd",
      "BLOG" => "blog",
      "CALENDAR" => "calendar",
      "COMMUNICATION" => "communication",
      "CRM" => "crm",
      "CURRENCY" => "currency",
      "DELIVERY" => "delivery",
      "DOCUMENTS" => "documents",
      "ECOMMERCE" => "ecommerce",
      "EVENTS" => "events",
      "EXPENSES" => "expenses",
      "FLEET" => "fleet",
      "FORUM" => "forum",
      "GAMIFICATION" => "gamification",
      "HELPDESK" => "helpdesk",
      "HR" => "hr",
      "INVENTORY" => "inventory",
      "KNOWLEDGE" => "knowledge",
      "LOYALTY" => "loyalty",
      "LUNCH" => "lunch",
      "MAINTENANCE" => "maintenance",
      "MANUFACTURING" => "manufacturing",
      "MARKETING" => "marketing",
      "MEMBERSHIP" => "membership",
      "ORGANIZATION" => "organization",
      "PAYMENT" => "payment",
      "PLM" => "plm",
      "POS" => "pos",
      "PROJECT" => "project",
      "PURCHASING" => "purchasing",
      "QUALITY" => "quality",
      "RATING" => "rating",
      "RENTAL" => "rental",
      "REPAIR" => "repair",
      "SALES" => "sales",
      "SIGN" => "sign",
      "SPREADSHEET" => "spreadsheet",
      "STUDIO" => "studio",
      "SUBSCRIPTIONS" => "subscriptions",
      "SURVEY" => "survey",
      "TRAVEL" => "travel",
      "UOM" => "uom",
      "WEBSITE" => "website",
      "DATA_RECYCLE" => "data_recycle",
      "E_LEARNING" => "e_learning",
      "IO_T" => "io_t",
      "LIVE_CHAT" => "live_chat",
      "OFBIZ_ACCOUNTING" => "ofbiz",
      "OFBIZ_COMMON" => "ofbiz",
      "OFBIZ_CONTENT" => "ofbiz_content",
      "OFBIZ_HUMAN_RES" => "ofbiz_human_res",
      "OFBIZ_MANUFACTURING" => "ofbiz_manufacturing",
      "OFBIZ_MARKETING" => "ofbiz_marketing",
      "OFBIZ_ORDER" => "ofbiz",
      "OFBIZ_PARTY" => "ofbiz",
      "OFBIZ_PRODUCT" => "ofbiz",
      "OFBIZ_SECURITY" => "ofbiz_security",
      "OFBIZ_SERVICE" => "ofbiz_service",
      "OFBIZ_SHIPMENT" => "ofbiz",
      "OFBIZ_WORK_EFFORT" => "ofbiz_work_effort",
    }
  end

  @doc "所有已注册的 Ash Domain 模块列表"
  def domains do
    [
      UniboExPoc.Accounting,
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Ofbiz.Accounting,
      UniboExPoc.Ofbiz.Common,
      UniboExPoc.Ofbiz.Order,
      UniboExPoc.Ofbiz.Party,
      UniboExPoc.Ofbiz.Product,
      UniboExPoc.Ofbiz.Shipment,
      UniboExPoc.Payment,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
    ]
  end
end
