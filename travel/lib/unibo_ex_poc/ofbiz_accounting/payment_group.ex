defmodule UniboExPoc.Ofbiz.Accounting.PaymentGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "付款分组"
  end

  postgres do
    table "accounting_payment_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_group

    queries do
      get :get_accounting_payment_group, :read
      list :list_accounting_payment_groups, :read
    end

    mutations do
      create :create_accounting_payment_group, :create
      update :update_accounting_payment_group, :update
      destroy :delete_accounting_payment_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_group_id, :string, public?: true
    attribute :payment_group_name, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_group_type, UniboExPoc.Ofbiz.Accounting.PaymentGroupType do
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
