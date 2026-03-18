defmodule UniboExPoc.BDD.Instructions.V1 do
  @moduledoc false

  use UniboExPoc.BDDC.Runtime, common_module: UniboExPoc.BDD.CommonInstructions

  # For runtime.caps.sync: keep an explicit, machine-readable pattern surface.
  # When you add new instructions, append a clause here.
  def __caps_sync_fixture__(tuple) do
    case tuple do
      {:given, :create_temp_dir} -> :ok
      {:given, :create_temp_file} -> :ok
      {:given, :given_seed_context} -> :ok
      {:when, :noop} -> :ok
      {:when, :when_execute_seed_contract} -> :ok
      {:then, :assert_noop} -> :ok
      {:then, :then_seed_contract_should_hold} -> :ok
      {:given, :given_graphql_schema_loaded} -> :ok
      {:when, :when_introspect_graphql_fields} -> :ok
      {:then, :then_graphql_contract_should_hold} -> :ok
    end
  end
end
