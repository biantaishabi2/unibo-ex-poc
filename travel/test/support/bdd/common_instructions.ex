defmodule UniboExPoc.BDD.CommonInstructions do
  @moduledoc false

  use UniboBddRuntime.CommonInstructions,
    registry_module: UniboExPoc.Generated.BddDomainRegistry,
    repo_module: UniboExPoc.Repo,
    otp_app: :travel
end
