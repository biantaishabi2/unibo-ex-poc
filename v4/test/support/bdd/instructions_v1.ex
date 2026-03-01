defmodule UniboV4.BDD.Instructions.V1 do
  @moduledoc false

  use UniboV4.BDDC.Runtime, common_module: UniboV4.BDD.CommonInstructions

  # For runtime.caps.sync: keep an explicit, machine-readable pattern surface.
  def __caps_sync_fixture__(tuple) do
    case tuple do
      {:given, :create_temp_dir} -> :ok
      {:given, :create_temp_file} -> :ok
      {:when, :noop} -> :ok
      {:then, :assert_noop} -> :ok
      {:given, :given_seed_context} -> :ok
      {:when, :when_execute_seed_contract} -> :ok
      {:then, :then_seed_contract_should_hold} -> :ok
    end
  end
end
