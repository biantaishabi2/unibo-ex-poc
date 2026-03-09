defmodule UniboExPoc.Ofbiz.Accounting.AcctgTransAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_acctg_trans_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_acctg_trans_attribute

    queries do
      get :get_accounting_acctg_trans_attribute, :read
      list :list_accounting_acctg_trans_attributes, :read
    end

    mutations do
      create :create_accounting_acctg_trans_attribute, :create
      update :update_accounting_acctg_trans_attribute, :update
      destroy :delete_accounting_acctg_trans_attribute, :destroy
    end

  end

  attributes do
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
    belongs_to :acctg_trans, UniboExPoc.Ofbiz.Accounting.AcctgTrans do
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
