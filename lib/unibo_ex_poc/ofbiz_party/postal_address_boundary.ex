defmodule UniboV4.Ofbiz.Party.PostalAddressBoundary do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_postal_address_boundaries"
    repo UniboV4.Repo
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
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :postal_address, UniboV4.Ofbiz.Party.PostalAddress do
      public? true
      source_attribute :contact_mech_id
    end
    belongs_to :geo, UniboV4.Ofbiz.Party.Geo do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
