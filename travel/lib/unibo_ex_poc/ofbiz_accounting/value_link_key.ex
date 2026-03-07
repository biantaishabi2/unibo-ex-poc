defmodule UniboExPoc.Ofbiz.Accounting.ValueLinkKey do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_value_link_keys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_value_link_key

    queries do
      get :get_accounting_value_link_key, :read
      list :list_accounting_value_link_keys, :read
    end

    mutations do
      create :create_accounting_value_link_key, :create
      update :update_accounting_value_link_key, :update
      destroy :delete_accounting_value_link_key, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :merchant_id, :string, public?: true
    attribute :public_key, :string, public?: true
    attribute :private_key, :string, public?: true
    attribute :exchange_key, :string, public?: true
    attribute :working_key, :string, public?: true
    attribute :working_key_index, :integer, public?: true
    attribute :last_working_key, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_terminal, :string, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_terminal, :string, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
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
