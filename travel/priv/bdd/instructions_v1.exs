# bddc instructions spec (v1)
#
# 说明：
# - 该文件必须返回一个 map：%{instruction_atom => spec_map}
# - 你可以手工维护，也可以预留 GENERATED 区域由 bddc registry.upsert 写入。

%{
  # BEGIN BDDC GENERATED
  # END BDDC GENERATED

  create_temp_dir: %{
    kind: :given,
    args: %{key: %{type: :string, required?: true, allowed: nil}},
    outputs: %{path: :string},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  create_temp_file: %{
    kind: :given,
    args: %{
      dir: %{type: :string, required?: true, allowed: nil},
      filename: %{type: :string, required?: true, allowed: nil},
      content: %{type: :string, required?: false, allowed: nil}
    },
    outputs: %{path: :string},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  noop: %{
    kind: :when,
    args: %{},
    outputs: %{},
    rules: [],
    scopes: [:unit, :integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  assert_noop: %{
    kind: :then,
    args: %{},
    outputs: %{},
    rules: [],
    scopes: [:unit, :integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: :weak
  },
  given_seed_context: %{
    kind: :given,
    args: %{
      id: %{type: :string, required?: true, allowed: nil},
      module: %{type: :string, required?: true, allowed: nil}
    },
    outputs: %{seed_id: :string, seed_module: :string},
    rules: [],
    scopes: [:unit, :integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  when_execute_seed_contract: %{
    kind: :when,
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    outputs: %{},
    rules: [],
    scopes: [:unit, :integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  then_seed_contract_should_hold: %{
    kind: :then,
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    outputs: %{},
    rules: [],
    scopes: [:unit, :integration, :e2e],
    boundary: :test_runtime,
    async?: false,
    eventually?: false,
    assert_class: :weak
  }
}
