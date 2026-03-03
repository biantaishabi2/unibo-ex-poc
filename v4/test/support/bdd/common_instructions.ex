defmodule UniboV4.BDD.CommonInstructions do
  @moduledoc false

  use UniboBddRuntime.CommonInstructions,
    registry_module: UniboV4.Generated.BddDomainRegistry,
    repo_module: UniboV4.Repo,
    otp_app: :unibo_v4
end
