defmodule UniboExPoc.Ofbiz.Common.CountryCode do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "ISO Country Code"
  end

  postgres do
    table "common_country_codes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_country_code

    queries do
      get :get_common_country_code, :read
      list :list_common_country_codes, :read
    end

    mutations do
      create :create_common_country_code, :create
      update :update_common_country_code, :update
      destroy :delete_common_country_code, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :country_code, :string, public?: true
    attribute :country_abbr, :string, public?: true
    attribute :country_number, :string, public?: true
    attribute :country_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
