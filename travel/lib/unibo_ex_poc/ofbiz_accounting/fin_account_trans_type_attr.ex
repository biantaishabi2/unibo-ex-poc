defmodule UniboExPoc.Ofbiz.Accounting.FinAccountTransTypeAttr do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fin_account_trans_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fin_account_trans_type_attr

    queries do
      get :get_accounting_fin_account_trans_type_attr, :read
      list :list_accounting_fin_account_trans_type_attrs, :read
    end

    mutations do
      create :create_accounting_fin_account_trans_type_attr, :create
      update :update_accounting_fin_account_trans_type_attr, :update
      destroy :delete_accounting_fin_account_trans_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fin_account_trans_type, UniboExPoc.Ofbiz.Accounting.FinAccountTransType do
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
