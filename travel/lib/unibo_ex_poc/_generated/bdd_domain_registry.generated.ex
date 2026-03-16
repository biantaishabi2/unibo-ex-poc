defmodule UniboExPoc.Generated.BddDomainRegistry do
  @moduledoc "自动生成的 BDD 域注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "BDD 域键 → Ash Domain 模块映射"
  def domain_map do
    %{
      "ACCOUNTING" => UniboExPoc.Accounting,
      "DELIVERY" => UniboExPoc.Delivery,
      "ECOMMERCE" => UniboExPoc.Ecommerce,
      "PAYMENT" => UniboExPoc.Payment,
      "PURCHASING" => UniboExPoc.Purchasing,
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
      "BDD" => "bdd",
      "DELIVERY" => "delivery",
      "ECOMMERCE" => "ecommerce",
      "PAYMENT" => "payment",
      "PURCHASING" => "purchasing",
      "SALES" => "sales",
      "TRAVEL" => "travel",
      "OFBIZ_ACCOUNTING" => "ofbiz_accounting",
      "OFBIZ_COMMON" => "ofbiz_common",
      "OFBIZ_ORDER" => "ofbiz_order",
      "OFBIZ_PARTY" => "ofbiz_party",
      "OFBIZ_PRODUCT" => "ofbiz_product",
      "OFBIZ_SHIPMENT" => "ofbiz_shipment",
    }
  end

  @doc "所有已注册的 Ash Domain 模块列表"
  def domains do
    [
      UniboExPoc.Accounting,
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Payment,
      UniboExPoc.Purchasing,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
    ]
  end
end
