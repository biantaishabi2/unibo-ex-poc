defmodule UniboExPoc.Organization.AuthDataScopeGrant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "角色的数据范围授权，表达 org_scope 边界下的过滤级别"
  end

  postgres do
    table "organization_auth_data_scope_grants"
    repo UniboExPoc.Repo
    identity_index_names unique_scope_grant_in_role: "idx_organization_auth_data_scope_grants_unique_scope_g_ef35eb7f"
  end

  graphql do
    type :organization_auth_data_scope_grant

    queries do
      get :get_organization_auth_data_scope_grant, :read
      list :list_organization_auth_data_scope_grants, :read
    end

    mutations do
      create :create_organization_auth_data_scope_grant, :create
      update :update_organization_auth_data_scope_grant, :update
      destroy :delete_organization_auth_data_scope_grant, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :scope_kind, :atom do
      allow_nil? false
      constraints one_of: [:self, :org_unit, :org_subtree, :company, :tenant_root]
      public? true
      description "数据范围级别"
    end
    attribute :combine_mode, :atom do
      allow_nil? false
      constraints one_of: [:max]
      default :max
      public? true
      description "多角色叠加时第一版固定取最大范围"
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
    belongs_to :anchor_party, UniboExPoc.Organization.Party do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Auth Data Scope Grant via Create. doc_url: graphql://contract/organization/create_organization_auth_data_scope_grant"
      primary? true
      accept [:scope_kind, :combine_mode, :role_id, :anchor_party_id]
      argument :role_id, :uuid, allow_nil?: false
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Auth Data Scope Grant via Update. doc_url: graphql://contract/organization/update_organization_auth_data_scope_grant"
      primary? true
      accept [:scope_kind, :combine_mode, :anchor_party_id]
      require_atomic? false
    end
  end

  identities do
    identity :unique_scope_grant_in_role, [:role_id, :scope_kind, :anchor_party_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
