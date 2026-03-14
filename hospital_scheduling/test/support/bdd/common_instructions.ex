defmodule HospitalScheduling.BDD.CommonInstructions do
  @moduledoc false

  use UniboBddRuntime.CommonInstructions,
    registry_module: HospitalScheduling.Generated.BddDomainRegistry,
    repo_module: HospitalScheduling.Repo,
    otp_app: :hospital_scheduling
end
