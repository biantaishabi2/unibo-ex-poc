defmodule UniboExPoc.Organization.AuthFeatureGrant do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "角色的功能权限授予，表达 capability/action 级授权"
  end

  postgres do
    table "organization_auth_feature_grants"
    repo UniboExPoc.Repo
    identity_index_names unique_feature_grant_in_role: "idx_organization_auth_feature_grants_unique_feature_gr_ab34adf5"
  end

  graphql do
    type :organization_auth_feature_grant

    queries do
      get :get_organization_auth_feature_grant, :read
      list :list_organization_auth_feature_grants, :read
    end

    mutations do
      create :create_organization_auth_feature_grant, :create
      update :update_organization_auth_feature_grant, :update
      destroy :delete_organization_auth_feature_grant, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :capability_key, :string do
      allow_nil? false
      public? true
      description "能力标识，不直接绑定旧菜单名"
    end
    attribute :action_key, :string do
      allow_nil? false
      public? true
      description "动作标识，例如 view/create/update/delete/approve"
    end
    attribute :effect, :atom do
      allow_nil? false
      constraints one_of: [:allow]
      default :allow
      public? true
      description "第一版先支持 allow"
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
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Auth Feature Grant via Create. doc_url: graphql://contract/organization/create_organization_auth_feature_grant"
      primary? true
      accept [:capability_key, :action_key, :effect, :role_id]
      argument :role_id, :uuid, allow_nil?: false
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Auth Feature Grant via Update. doc_url: graphql://contract/organization/update_organization_auth_feature_grant"
      primary? true
      accept [:effect]
      require_atomic? false
    end
  end

  identities do
    identity :unique_feature_grant_in_role, [:role_id, :capability_key, :action_key]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end


  pub_sub do
    module UniboExPoc.PubSub
    prefix "auth_feature_grant"

    publish :create, ["authz.feature_grant.granted"]
    publish :destroy, ["authz.feature_grant.revoked"]
  end
end
