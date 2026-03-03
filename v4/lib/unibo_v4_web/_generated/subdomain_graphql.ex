defmodule UniboV4Web.Generated.SubdomainGraphql do
  @moduledoc "自动生成的子域 GraphQL 路由映射 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "返回子域名 → Schema 模块的映射"
  def subdomains do
    %{
      calendar: UniboV4Web.Generated.Schema.Calendar,
      engagement: UniboV4Web.Generated.Schema.Engagement,
      finance: UniboV4Web.Generated.Schema.Finance,
      hr: UniboV4Web.Generated.Schema.Hr,
      knowledge: UniboV4Web.Generated.Schema.Knowledge,
      learning: UniboV4Web.Generated.Schema.Learning,
      marketing: UniboV4Web.Generated.Schema.Marketing,
      platform: UniboV4Web.Generated.Schema.Platform,
      production: UniboV4Web.Generated.Schema.Production,
      project: UniboV4Web.Generated.Schema.Project,
      purchasing: UniboV4Web.Generated.Schema.Purchasing,
      sales: UniboV4Web.Generated.Schema.Sales,
    }
  end
end
