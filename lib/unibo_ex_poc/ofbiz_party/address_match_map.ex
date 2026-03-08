defmodule UniboV4.Ofbiz.Party.AddressMatchMap do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_address_match_maps"
    repo UniboV4.Repo
  end

  graphql do
    type :party_address_match_map

    queries do
      get :get_party_address_match_map, :read
      list :list_party_address_match_maps, :read
    end

    mutations do
      create :create_party_address_match_map, :create
      update :update_party_address_match_map, :update
      destroy :delete_party_address_match_map, :destroy
    end

  end

  attributes do
    attribute :map_key, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "映射键"
    end
    attribute :map_value, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "映射值"
    end
    attribute :sequence_num, :integer do
      public? true
      description "序列编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
