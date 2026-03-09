defmodule UniboExPoc.Ofbiz.Accounting.RateType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_rate_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_rate_type

    queries do
      get :get_accounting_rate_type, :read
      list :list_accounting_rate_types, :read
    end

    mutations do
      create :create_accounting_rate_type, :create
      update :update_accounting_rate_type, :update
      destroy :delete_accounting_rate_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :rate_type_id, :string, public?: true
    attribute :description, :string, public?: true
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
