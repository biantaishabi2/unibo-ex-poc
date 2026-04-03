defmodule UniboExPoc.Generated.ImportExportRegistry do
  @moduledoc "自动生成的导入导出注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  def configs do
    %{
      UniboExPoc.Organization.PersonProfile => %{
        formats: [:excel, :csv],
        export_fields: [:full_name, :mobile, :employee_code, :national_id, :gender, :join_channel, :member_status, :archived_reason, :archived_at],
        import_action: :create,
        max_import_rows: 10_000
      },
    }
  end

  def enabled?(resource), do: Map.has_key?(configs(), resource)
  def config(resource), do: Map.get(configs(), resource)
end
