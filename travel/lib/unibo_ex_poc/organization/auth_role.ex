defmodule UniboExPoc.Organization.AuthRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "角色定义，承载功能授权与数据范围授权的聚合根"
  end

  postgres do
    table "organization_auth_roles"
    repo UniboExPoc.Repo
    identity_index_names unique_role_code: "idx_organization_auth_roles_unique_role_code"
  end

  graphql do
    type :organization_auth_role

    queries do
      get :get_organization_auth_role, :read
      list :list_organization_auth_roles, :read
    end

    mutations do
      create :create_organization_auth_role, :create
      update :update_organization_auth_role, :update
      update :activate_organization_auth_role, :activate
      update :disable_organization_auth_role, :disable
      destroy :delete_organization_auth_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role_code, :string do
      allow_nil? false
      public? true
      description "角色稳定编码"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "角色名称"
    end
    attribute :description, :string do
      public? true
      description "角色说明"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :disabled]
      default :draft
      public? true
      description "角色状态"
    end
    attribute :built_in, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否为内建角色"
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :feature_grants, UniboExPoc.Organization.AuthFeatureGrant do
      public? true
      destination_attribute :role_id
    end
    has_many :data_scope_grants, UniboExPoc.Organization.AuthDataScopeGrant do
      public? true
      destination_attribute :role_id
    end
    has_many :bindings, UniboExPoc.Organization.AuthRoleBinding do
      public? true
      destination_attribute :role_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Auth Role via Create. doc_url: graphql://contract/organization/create_organization_auth_role"
      primary? true
      accept [:role_code, :name, :description, :status, :built_in]
    end
    update :update do
      description "Update Auth Role via Update. doc_url: graphql://contract/organization/update_organization_auth_role"
      primary? true
      accept [:name, :description, :status]
      require_atomic? false
    end
    update :activate do
      description "激活角色，从 draft 进入 active 状态

激活角色，从 draft 进入 active 状态. doc_url: graphql://contract/organization/activate_organization_auth_role"
      accept []
      change set_attribute(:status, :active)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :disable do
      description "禁用角色

禁用角色. doc_url: graphql://contract/organization/disable_organization_auth_role"
      accept []
      change set_attribute(:status, :disabled)
      change AshStateMachine.BuiltinChanges.transition_state(:disabled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_role_code, [:role_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:feature_grants, :data_scope_grants, :bindings]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:draft, :active, :disabled]
    state_attribute :status
    transitions do
      transition :activate, from: :draft, to: :active
      transition :disable, from: :active, to: :disabled
      transition :disable, from: :draft, to: :disabled
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "auth_role"

    publish :create, ["authz.role.created"]
    publish :update, ["authz.role.updated"]
    publish :activate, ["authz.role.activated"]
  end
end
