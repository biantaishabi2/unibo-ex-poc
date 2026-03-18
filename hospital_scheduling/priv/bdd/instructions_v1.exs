# bddc instructions spec (v1)
#
# 该文件必须返回一个 map：%{instruction_atom => spec_map}

%{
  # -- seed 通用指令 --
  given_seed_context: %{
    args: %{id: %{type: :string, required?: true, allowed: nil}, module: %{type: :string, required?: true, allowed: nil}},
    kind: :given,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  when_execute_seed_contract: %{
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    kind: :when,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  then_seed_contract_should_hold: %{
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    kind: :then,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  },

  # -- graphql contract 指令 --
  given_graphql_schema_loaded: %{
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    kind: :given,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  when_introspect_graphql_fields: %{
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    kind: :when,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  },
  then_graphql_contract_should_hold: %{
    args: %{module: %{type: :string, required?: true, allowed: nil}},
    kind: :then,
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
}
