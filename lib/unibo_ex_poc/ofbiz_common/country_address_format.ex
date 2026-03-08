defmodule UniboV4.Ofbiz.Common.CountryAddressFormat do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "common_country_address_formats"
    repo UniboV4.Repo
  end

  graphql do
    type :common_country_address_format

    queries do
      get :get_common_country_address_format, :read
      list :list_common_country_address_formats, :read
    end

    mutations do
      create :create_common_country_address_format, :create
      update :update_common_country_address_format, :update
      destroy :delete_common_country_address_format, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :require_state_province_id, :string, public?: true
    attribute :require_postal_code, :boolean, public?: true
    attribute :postal_code_regex, :string, public?: true
    attribute :has_postal_code_ext, :boolean, public?: true
    attribute :require_postal_code_ext, :boolean, public?: true
    attribute :address_format, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :geo, UniboV4.Ofbiz.Common.Geo do
      public? true
    end
    belongs_to :geo_assoc_type, UniboV4.Ofbiz.Common.GeoAssocType do
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
