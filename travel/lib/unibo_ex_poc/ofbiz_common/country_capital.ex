defmodule UniboExPoc.Ofbiz.Common.CountryCapital do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Country Capital"
  end

  postgres do
    table "common_country_capitals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_country_capital

    queries do
      get :get_common_country_capital, :read
      list :list_common_country_capitals, :read
    end

    mutations do
      create :create_common_country_capital, :create
      update :update_common_country_capital, :update
      destroy :delete_common_country_capital, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :country_capital, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :country_code_rel, UniboExPoc.Ofbiz.Common.CountryCode do
      public? true
      source_attribute :country_code
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
