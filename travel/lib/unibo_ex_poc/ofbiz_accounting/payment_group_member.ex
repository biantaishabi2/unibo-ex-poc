defmodule UniboExPoc.Ofbiz.Accounting.PaymentGroupMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "付款分组 Member"
  end

  postgres do
    table "accounting_payment_group_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_group_member

    queries do
      get :get_accounting_payment_group_member, :read
      list :list_accounting_payment_group_members, :read
    end

    mutations do
      create :create_accounting_payment_group_member, :create
      update :update_accounting_payment_group_member, :update
      destroy :delete_accounting_payment_group_member, :destroy
    end

  end

  attributes do
    attribute :payment_group_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :payment_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_group, UniboExPoc.Ofbiz.Accounting.PaymentGroup do
      public? true
      define_attribute? false
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
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
