defmodule UniboExPoc.Ofbiz.Accounting.FinAccountTransAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_trans_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account_trans_attribute

    queries do
      get :get_accounting_fin_account_trans_attribute, :read
      list :list_accounting_fin_account_trans_attributes, :read
    end

    mutations do
      create :create_accounting_fin_account_trans_attribute, :create
      update :update_accounting_fin_account_trans_attribute, :update
      destroy :delete_accounting_fin_account_trans_attribute, :destroy
    end

  end

  attributes do
    attribute :fin_account_trans_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fin_account_trans, UniboExPoc.Ofbiz.Accounting.FinAccountTrans do
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
