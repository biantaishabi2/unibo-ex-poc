defmodule HospitalScheduling.Generated.BddDomainRegistry do
  @moduledoc "自动生成的 BDD 域注册表 — 由 UniBO 编译器生成，请勿手动编辑"

  @doc "BDD 域键 → Ash Domain 模块映射"
  def domain_map do
    %{
      "SCHEDULING" => HospitalScheduling.Scheduling
    }
  end

  @doc "BDD 域键 → 目录名映射"
  def module_dirs do
    %{
      "BDD" => "bdd",
      "SCHEDULING" => "scheduling"
    }
  end

  @doc "所有已注册的 Ash Domain 模块列表"
  def domains do
    [
      HospitalScheduling.Scheduling
    ]
  end
end
