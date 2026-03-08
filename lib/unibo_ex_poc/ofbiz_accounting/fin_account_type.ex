defmodule UniboV4.Ofbiz.Accounting.FinAccountType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_types"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_fin_account_type

    queries do
      get :get_accounting_fin_account_type, :read
      list :list_accounting_fin_account_types, :read
    end

    mutations do
      create :create_accounting_fin_account_type, :create
      update :update_accounting_fin_account_type, :update
      destroy :delete_accounting_fin_account_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fin_account_type_id, :string, public?: true
    attribute :replenish_enum_id, :string, public?: true
    attribute :is_refundable, :boolean, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_fin_account_type, UniboV4.Ofbiz.Accounting.FinAccountType do
      public? true
      source_attribute :parent_type_id
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
