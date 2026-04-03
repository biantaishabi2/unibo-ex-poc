defmodule UniboExPoc.Organization.TenantModuleGrant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine]

  resource do
    description "租户模块开通记录，表达租户对某个模块的能力开关"
  end

  postgres do
    table "organization_tenant_module_grants"
    repo UniboExPoc.Repo
    identity_index_names unique_tenant_module: "idx_organization_tenant_module_grants_unique_tenant_module"
  end

  graphql do
    type :organization_tenant_module_grant

    queries do
      get :get_organization_tenant_module_grant, :read
      list :list_organization_tenant_module_grants, :read
    end

    mutations do
      create :create_grant_module_organization_tenant_module_grant, :grant_module
      update :revoke_module_organization_tenant_module_grant, :revoke_module
      update :restore_module_organization_tenant_module_grant, :restore_module
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :module_key, :string do
      allow_nil? false
      public? true
      description "模块标识"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:enabled, :disabled]
      default :enabled
      public? true
      description "模块开通状态"
    end
    attribute :enabled_at, :utc_datetime do
      public? true
      description "开通时间"
    end
    attribute :disabled_at, :utc_datetime do
      public? true
      description "关闭时间"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :tenant, UniboExPoc.Organization.Tenant do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :grant_module do
      description "Create Tenant Module Grant via Grant Module. doc_url: graphql://contract/organization/create_grant_module_organization_tenant_module_grant"
      primary? true
      accept [:tenant_id, :module_key]
      argument :tenant_id, :uuid, allow_nil?: false
      change manage_relationship(:tenant_id, :tenant, type: :append, on_lookup: :relate)
      change set_attribute(:status, :enabled)
      change set_attribute(:enabled_at, &DateTime.utc_now/0)
    end
    update :revoke_module do
      description "Update Tenant Module Grant via Revoke Module. doc_url: graphql://contract/organization/revoke_module_organization_tenant_module_grant"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :enabled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :enabled}))
        end
      end
      # message: "只有已开通模块可以关闭"
      change set_attribute(:status, :disabled)
      change set_attribute(:disabled_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:disabled)
      require_atomic? false
    end
    update :restore_module do
      description "Update Tenant Module Grant via Restore Module. doc_url: graphql://contract/organization/restore_module_organization_tenant_module_grant"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :disabled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :disabled}))
        end
      end
      # message: "只有已关闭模块可以恢复"
      change set_attribute(:status, :enabled)
      change set_attribute(:enabled_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:enabled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_tenant_module, [:tenant_id, :module_key]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:enabled]
    default_initial_state :enabled
    extra_states [:enabled, :disabled]
    state_attribute :status
    transitions do
      transition :revoke_module, from: :enabled, to: :disabled
      transition :restore_module, from: :disabled, to: :enabled
    end
  end
end
