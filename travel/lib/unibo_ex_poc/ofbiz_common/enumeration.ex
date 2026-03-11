defmodule UniboExPoc.Ofbiz.Common.Enumeration do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Enumeration"
  end

  postgres do
    table "common_enumerations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_common_enumeration

    queries do
      get :get_ofbiz_common_enumeration, :read
      list :list_ofbiz_common_enumerations, :read
    end

    mutations do
      create :create_ofbiz_common_enumeration, :create
      update :update_ofbiz_common_enumeration, :update
      destroy :delete_ofbiz_common_enumeration, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :enum_id, :string, public?: true
    attribute :enum_code, :string, public?: true
    attribute :sequence_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :enumeration_type, UniboExPoc.Ofbiz.Common.EnumerationType do
      public? true
      source_attribute :enum_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
