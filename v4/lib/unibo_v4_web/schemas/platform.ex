defmodule UniboV4Web.Schema.Platform do
  @moduledoc "平台工具子域 — Approvals, DataRecycle, Spreadsheet, Studio, IoT"
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Approvals,
      UniboV4.DataRecycle,
      UniboV4.Spreadsheet,
      UniboV4.Studio,
      UniboV4.IoT
    ]

  query do
  end

  mutation do
  end
end
