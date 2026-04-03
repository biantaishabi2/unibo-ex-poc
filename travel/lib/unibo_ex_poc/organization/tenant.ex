defmodule UniboExPoc.Organization.Tenant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "租户主实体，表达平台隔离与能力发布边界"
  end

  postgres do
    table "organization_tenants"
    repo UniboExPoc.Repo
    identity_index_names unique_tenant_code: "idx_organization_tenants_unique_tenant_code"
  end

  graphql do
    type :organization_tenant

    queries do
      get :get_organization_tenant, :read
      list :list_organization_tenants, :read
    end

    mutations do
      create :create_create_tenant_organization_tenant, :create_tenant
      update :update_tenant_organization_tenant, :update_tenant
      update :activate_tenant_organization_tenant, :activate_tenant
      update :suspend_tenant_organization_tenant, :suspend_tenant
      update :archive_tenant_organization_tenant, :archive_tenant
      update :replace_admin_organization_tenant, :replace_admin
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tenant_code, :string do
      allow_nil? false
      public? true
      description "租户稳定编码"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "租户名称"
    end
    attribute :tenant_type, :atom do
      allow_nil? false
      constraints one_of: [:company, :group, :platform]
      public? true
      description "租户类型，用于区分公司、集团和平台级租户"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :suspended, :archived]
      default :draft
      public? true
      description "租户生命周期状态"
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
    belongs_to :root_organization, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
    belongs_to :current_admin_party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
    has_many :module_grants, UniboExPoc.Organization.TenantModuleGrant do
      public? true
      destination_attribute :tenant_id
    end
  end

  actions do
    defaults [:read]
    create :create_tenant do
      description "Create Tenant via Create Tenant. doc_url: graphql://contract/organization/create_create_tenant_organization_tenant"
      primary? true
      accept [:tenant_code, :name, :tenant_type, :root_organization_id, :current_admin_party_id]
      argument :root_organization_id, :uuid, allow_nil?: false
      change manage_relationship(:root_organization_id, :root_organization, type: :append, on_lookup: :relate)
      argument :current_admin_party_id, :uuid, allow_nil?: false
      change manage_relationship(:current_admin_party_id, :current_admin_party, type: :append, on_lookup: :relate)
      validate present(:root_organization_id)
      # message: "创建租户必须绑定根组织"
      validate present(:current_admin_party_id)
      # message: "创建租户必须绑定主管理员"
    end
    update :update_tenant do
      description "Update Tenant via Update Tenant. doc_url: graphql://contract/organization/update_tenant_organization_tenant"
      primary? true
      accept [:name, :tenant_type]
      require_atomic? false
    end
    update :activate_tenant do
      description "Update Tenant via Activate Tenant. doc_url: graphql://contract/organization/activate_tenant_organization_tenant"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :suspended] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :suspended]}))
        end
      end
      # message: "只有草稿或停用中的租户可以激活"
      change set_attribute(:status, :active)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :suspend_tenant do
      description "Update Tenant via Suspend Tenant. doc_url: graphql://contract/organization/suspend_tenant_organization_tenant"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有已激活租户可以停用"
      change set_attribute(:status, :suspended)
      change AshStateMachine.BuiltinChanges.transition_state(:suspended)
      require_atomic? false
    end
    update :archive_tenant do
      description "Update Tenant via Archive Tenant. doc_url: graphql://contract/organization/archive_tenant_organization_tenant"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :suspended] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :suspended]}))
        end
      end
      # message: "只有草稿或停用中的租户可以归档"
      change set_attribute(:status, :archived)
      change AshStateMachine.BuiltinChanges.transition_state(:archived)
      require_atomic? false
    end
    update :replace_admin do
      description "Update Tenant via Replace Admin. doc_url: graphql://contract/organization/replace_admin_organization_tenant"
      accept []
      argument :admin_party_id, :uuid
      change set_attribute(:current_admin_party_id, expr(^arg(:admin_party_id)))
      require_atomic? false
    end
  end

  identities do
    identity :unique_tenant_code, [:tenant_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:draft, :active, :suspended, :archived]
    state_attribute :status
    transitions do
      transition :activate_tenant, from: :draft, to: :active
      transition :activate_tenant, from: :suspended, to: :active
      transition :suspend_tenant, from: :active, to: :suspended
      transition :archive_tenant, from: :draft, to: :archived
      transition :archive_tenant, from: :suspended, to: :archived
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "tenant"

    publish :activate_tenant, ["tenant.tenant.activated"]
    publish :archive_tenant, ["tenant.tenant.archived"]
  end
end
