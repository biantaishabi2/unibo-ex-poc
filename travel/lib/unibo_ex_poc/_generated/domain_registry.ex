defmodule UniboExPoc.Generated.DomainRegistry do
  @moduledoc "自动生成的域注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "返回所有已注册的 Ash Domain 模块列表"
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
