defmodule UniboExPoc.Organization.AuthRoleBinding do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "角色与主体绑定，表达一人多角色授权关系"
  end

  postgres do
    table "organization_auth_role_bindings"
    repo UniboExPoc.Repo
    identity_index_names unique_role_binding: "idx_organization_auth_role_bindings_unique_role_binding"
  end

  graphql do
    type :organization_auth_role_binding

    queries do
      get :get_organization_auth_role_binding, :read
      list :list_organization_auth_role_bindings, :read
    end

    mutations do
      create :create_organization_auth_role_binding, :create
      update :update_organization_auth_role_binding, :update
      update :enable_organization_auth_role_binding, :enable
      update :disable_organization_auth_role_binding, :disable
      destroy :delete_organization_auth_role_binding, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :binding_status, :atom do
      allow_nil? false
      constraints one_of: [:active, :disabled]
      default :active
      public? true
      description "绑定状态"
    end
    attribute :starts_at, :utc_datetime do
      public? true
      description "绑定起始时间"
    end
    attribute :ends_at, :utc_datetime do
      public? true
      description "绑定结束时间"
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
    belongs_to :role, UniboExPoc.Organization.AuthRole do
      public? true
      allow_nil? false
    end
    belongs_to :party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Auth Role Binding via Create. doc_url: graphql://contract/organization/create_organization_auth_role_binding"
      primary? true
      accept [:binding_status, :starts_at, :ends_at, :role_id, :party_id]
      argument :role_id, :uuid, allow_nil?: false
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
      argument :party_id, :uuid, allow_nil?: false
      change manage_relationship(:party_id, :party, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Auth Role Binding via Update. doc_url: graphql://contract/organization/update_organization_auth_role_binding"
      primary? true
      accept [:binding_status, :starts_at, :ends_at]
      require_atomic? false
    end
    update :enable do
      description "启用角色绑定

启用角色绑定. doc_url: graphql://contract/organization/enable_organization_auth_role_binding"
      accept []
      change set_attribute(:binding_status, :active)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :disable do
      description "禁用角色绑定

禁用角色绑定. doc_url: graphql://contract/organization/disable_organization_auth_role_binding"
      accept []
      change set_attribute(:binding_status, :disabled)
      change AshStateMachine.BuiltinChanges.transition_state(:disabled)
      require_atomic? false
    end
  end

  identities do
    identity :unique_role_binding, [:role_id, :party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end


  state_machine do
    initial_states [:active]
    default_initial_state :active
    extra_states [:active, :disabled]
    state_attribute :binding_status
    transitions do
      transition :disable, from: :active, to: :disabled
      transition :enable, from: :disabled, to: :active
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "auth_role_binding"

    publish :create, ["authz.role_binding.created"]
    publish :destroy, ["authz.role_binding.removed"]
  end
end
