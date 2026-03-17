defmodule UniboExPoc.Ofbiz.Party.RoleType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_role_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_party_role_type

    queries do
      get :get_ofbiz_party_role_type, :read
      list :list_ofbiz_party_role_types, :read
    end

    mutations do
      create :create_ofbiz_party_role_type, :create
      update :update_ofbiz_party_role_type, :update
      destroy :delete_ofbiz_party_role_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role_type_id, :string do
      public? true
      description "角色类型编号"
    end
    attribute :has_table, :boolean do
      public? true
      description "有表"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :parent_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
