defmodule UniboExPoc.Ofbiz.Common.EnumerationType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Enumeration Type"
  end

  postgres do
    table "common_enumeration_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_common_enumeration_type

    queries do
      get :get_ofbiz_common_enumeration_type, :read
      list :list_ofbiz_common_enumeration_types, :read
    end

    mutations do
      create :create_ofbiz_common_enumeration_type, :create
      update :update_ofbiz_common_enumeration_type, :update
      destroy :delete_ofbiz_common_enumeration_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :enum_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_enumeration_type, UniboExPoc.Ofbiz.Common.EnumerationType do
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
