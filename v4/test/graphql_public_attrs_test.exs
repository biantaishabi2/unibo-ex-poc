defmodule UniboV4.GraphqlPublicAttrsTest do
  @moduledoc """
  门禁测试：确保所有 Ash Resource 的业务属性都设置了 public? true，
  否则 AshGraphql 不会在 GraphQL type 中暴露这些字段。
  """
  use ExUnit.Case, async: true

  @domains [
    UniboV4.Accounting,
    UniboV4.Sales,
    UniboV4.Purchasing,
    UniboV4.CRM,
    UniboV4.HR,
    UniboV4.Inventory,
    UniboV4.Manufacturing,
    UniboV4.Marketing,
    UniboV4.Ecommerce,
    UniboV4.Expenses,
    UniboV4.Helpdesk,
    UniboV4.Maintenance,
    UniboV4.Communication,
    UniboV4.POS,
    UniboV4.Project
  ]

  # 自动跳过的系统属性
  @system_attrs [:id, :inserted_at, :updated_at]

  test "所有 GraphQL Resource 的业务属性必须设置 public? true" do
    problems =
      Enum.flat_map(@domains, fn domain ->
        domain
        |> Ash.Domain.Info.resources()
        |> Enum.flat_map(fn resource ->
          non_public =
            resource
            |> Ash.Resource.Info.attributes()
            |> Enum.reject(fn attr ->
              attr.name in @system_attrs or attr.primary_key? or attr.public?
            end)

          if non_public == [] do
            []
          else
            resource_name = resource |> Module.split() |> Enum.join(".")
            fields = Enum.map(non_public, & &1.name)
            [{resource_name, fields}]
          end
        end)
      end)

    if problems != [] do
      msg =
        problems
        |> Enum.map(fn {name, fields} ->
          "  #{name}: #{Enum.join(fields, ", ")}"
        end)
        |> Enum.join("\n")

      flunk("""
      以下 Resource 的属性缺少 public? true（GraphQL 不会暴露这些字段）：

      #{msg}

      修复方法：给对应属性加上 public? true
      """)
    end
  end

  test "所有 GraphQL Resource 的 belongs_to 关系必须设置 public? true" do
    problems =
      Enum.flat_map(@domains, fn domain ->
        domain
        |> Ash.Domain.Info.resources()
        |> Enum.flat_map(fn resource ->
          non_public =
            resource
            |> Ash.Resource.Info.relationships()
            |> Enum.filter(&(&1.type == :belongs_to))
            |> Enum.reject(& &1.public?)

          if non_public == [] do
            []
          else
            resource_name = resource |> Module.split() |> Enum.join(".")
            rels = Enum.map(non_public, & &1.name)
            [{resource_name, rels}]
          end
        end)
      end)

    if problems != [] do
      msg =
        problems
        |> Enum.map(fn {name, rels} ->
          "  #{name}: #{Enum.join(rels, ", ")}"
        end)
        |> Enum.join("\n")

      flunk("""
      以下 Resource 的 belongs_to 关系缺少 public? true（GraphQL 不会暴露关联字段）：

      #{msg}

      修复方法：给对应 belongs_to 加上 public? true
      """)
    end
  end
end
