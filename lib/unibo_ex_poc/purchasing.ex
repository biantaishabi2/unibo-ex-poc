defmodule UniboExPoc.Purchasing do
  @moduledoc """
  采购领域 — 基于 OFBiz Order 模块的标准实体模型。

  核心聚合根：Order（OrderHeader + OrderItem）
  支撑实体：Party（供应商/买方）、Product（产品）
  """
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    # 自动暴露所有 resource 的 queries/mutations
    authorize? false
  end

  resources do
    resource UniboExPoc.Purchasing.Party
    resource UniboExPoc.Purchasing.Product
    resource UniboExPoc.Purchasing.Order
    resource UniboExPoc.Purchasing.OrderItem
  end
end
