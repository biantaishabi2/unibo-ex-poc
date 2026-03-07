defmodule UniboExPoc.Ofbiz.Party.PostalAddressBoundary do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "party_postal_address_boundaries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_postal_address_boundary

    queries do
      get :get_party_postal_address_boundary, :read
      list :list_party_postal_address_boundarys, :read
    end

    mutations do
      create :create_party_postal_address_boundary, :create
      update :update_party_postal_address_boundary, :update
      destroy :delete_party_postal_address_boundary, :destroy
    end

  end

  attributes do
    attribute :contact_mech_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "联系方式编号"
    end
    attribute :geo_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "地理编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :postal_address, UniboExPoc.Ofbiz.Party.PostalAddress do
      public? true
      source_attribute :contact_mech_id
      define_attribute? false
    end
    belongs_to :geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
