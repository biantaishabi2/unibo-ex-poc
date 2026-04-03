defmodule UniboExPoc.Organization.Party do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description "统一主体，可以是自然人或组织实体，是所有业务角色和关系的基础"
  end

  postgres do
    table "organization_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :organization_party

    queries do
      get :get_organization_party, :read
      list :list_organization_partys, :read
    end

    mutations do
      create :create_organization_party, :create
      update :update_organization_party, :update
      destroy :delete_organization_party, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "主体名称"
    end
    attribute :party_type, :atom do
      allow_nil? false
      constraints one_of: [:person, :organization]
      public? true
      description "主体类型——区分自然人与组织"
    end
    attribute :description, :string do
      public? true
      description "可选描述信息"
    end
    attribute :external_id, :string do
      public? true
      description "外部系统编号，用于与外部系统对接"
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

  calculations do
    calculate :org_scope, :string, expr(custom)
  end

  relationships do
    has_many :roles, UniboExPoc.Organization.PartyRole do
      public? true
      destination_attribute :party_id
    end
    has_many :outgoing_relationships, UniboExPoc.Organization.PartyRelationship do
      public? true
      destination_attribute :from_party_id
    end
    has_many :incoming_relationships, UniboExPoc.Organization.PartyRelationship do
      public? true
      destination_attribute :to_party_id
    end
    has_many :auth_role_bindings, UniboExPoc.Organization.AuthRoleBinding do
      public? true
      destination_attribute :party_id
    end
    has_many :auth_data_scope_anchors, UniboExPoc.Organization.AuthDataScopeGrant do
      public? true
      destination_attribute :anchor_party_id
    end
    has_many :person_profiles, UniboExPoc.Organization.PersonProfile do
      public? true
      destination_attribute :person_party_id
    end
    has_many :org_person_profiles, UniboExPoc.Organization.PersonProfile do
      public? true
      destination_attribute :current_org_party_id
    end
    has_many :tenants_as_root, UniboExPoc.Organization.Tenant do
      public? true
      destination_attribute :root_organization_id
    end
    has_many :tenants_as_admin, UniboExPoc.Organization.Tenant do
      public? true
      destination_attribute :current_admin_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Party via Create. doc_url: graphql://contract/organization/create_organization_party"
      primary? true
      accept [:name, :party_type, :description, :external_id]
    end
    update :update do
      description "Update Party via Update. doc_url: graphql://contract/organization/update_organization_party"
      primary? true
      accept [:name, :description, :external_id]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:roles, :outgoing_relationships, :incoming_relationships, :auth_role_bindings, :auth_data_scope_anchors, :person_profiles, :org_person_profiles, :tenants_as_root, :tenants_as_admin]
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(^actor(:role) == :admin)
      access_type :filter
      forbid_unless {UniboExPoc.Organization.OrgScopeChecks.PartyInScope, []}
      authorize_if always()
    end
    policy action_type(:create) do
      authorize_if expr(^actor(:role) == :admin)
    end
    policy action_type(:update) do
      authorize_if expr(^actor(:role) == :admin or ^actor(:party_id) == id and party_type == :person)
    end
    policy action_type(:destroy) do
      authorize_if expr(^actor(:role) == :admin)
    end
    policy always() do
      authorize_if always()
    end
  end

end
