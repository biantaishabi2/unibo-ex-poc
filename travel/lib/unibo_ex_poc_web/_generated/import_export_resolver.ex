defmodule UniboExPocWeb.Generated.ImportExportResolver do
  @moduledoc "导入导出 GraphQL Resolver（自动生成，请勿手动修改）"

  alias UniboExPoc.Generated.ImportExportRegistry

  @resource_map %{
    "person_profile" => UniboExPoc.Organization.PersonProfile,
  }

  @domain_map %{
    UniboExPoc.Organization.PersonProfile => UniboExPoc.Organization,
  }

  def import_organization_person_profile(%{file: %Plug.Upload{path: path}, format: format}, resolution) do
    actor = resolution.context[:current_user]
    format_atom = parse_format(format)
    case UniboImportExport.import(UniboExPoc.Organization.PersonProfile, format_atom, path,
      registry: ImportExportRegistry, domain: UniboExPoc.Organization, actor: actor) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  def import_organization_person_profile(%{file: %Plug.Upload{path: path}}, resolution) do
    actor = resolution.context[:current_user]
    case UniboImportExport.import(UniboExPoc.Organization.PersonProfile, :excel, path,
      registry: ImportExportRegistry, domain: UniboExPoc.Organization, actor: actor) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  def export_organization_person_profile(%{format: format}, _resolution) do
    format_str = format || "excel"
    ext = if format_str == "csv", do: "csv", else: "xlsx"
    {:ok, %{download_url: "/api/ie/export/person_profile?format=#{format_str}", filename: "person_profile.#{ext}"}}
  end

  def export_organization_person_profile(%{}, _resolution) do
    {:ok, %{download_url: "/api/ie/export/person_profile?format=excel", filename: "person_profile.xlsx"}}
  end

  defp parse_format("csv"), do: :csv
  defp parse_format("excel"), do: :excel
  defp parse_format(nil), do: :excel
  defp parse_format(_), do: :excel
end
