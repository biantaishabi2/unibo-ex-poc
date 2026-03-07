defmodule UniboExPoc.Generated.DomainRegistry do
  @moduledoc "自动生成的域注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "返回所有已注册的 Ash Domain 模块列表"
  def domains do
    [
      UniboExPoc.Delivery,
      UniboExPoc.Ecommerce,
      UniboExPoc.Ofbiz.Accounting,
      UniboExPoc.Ofbiz.Common,
      UniboExPoc.Ofbiz.Content,
      UniboExPoc.Ofbiz.Order,
      UniboExPoc.Ofbiz.Party,
      UniboExPoc.Ofbiz.Product,
      UniboExPoc.Ofbiz.Shipment,
      UniboExPoc.Payment,
      UniboExPoc.Sales,
      UniboExPoc.Travel,
      UniboExPoc.Website,
    ]
  end
end
