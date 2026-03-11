defmodule UniboExPoc.Ofbiz.Accounting.CreditCard do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_credit_cards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_credit_card

    queries do
      get :get_ofbiz_accounting_credit_card, :read
      list :list_ofbiz_accounting_credit_cards, :read
    end

    mutations do
      create :create_ofbiz_accounting_credit_card, :create
      update :update_ofbiz_accounting_credit_card, :update
      destroy :delete_ofbiz_accounting_credit_card, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :card_type, :string, public?: true
    attribute :card_number, :string, public?: true
    attribute :valid_from_date, :string do
      public? true
      description "在世界的某些地区不常见。"
    end
    attribute :expire_date, :string, public?: true
    attribute :issue_number, :string do
      public? true
      description "某些银行卡（如Switch和Maestro）上的单个数字"
    end
    attribute :company_name_on_card, :string, public?: true
    attribute :title_on_card, :string, public?: true
    attribute :first_name_on_card, :string, public?: true
    attribute :middle_name_on_card, :string, public?: true
    attribute :last_name_on_card, :string, public?: true
    attribute :suffix_on_card, :string, public?: true
    attribute :contact_mech_id, :string do
      public? true
      description "账单邮寄地址"
    end
    attribute :consecutive_failed_auths, :integer, public?: true
    attribute :last_failed_auth_date, :utc_datetime, public?: true
    attribute :consecutive_failed_nsf, :integer, public?: true
    attribute :last_failed_nsf_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboExPoc.Ofbiz.Accounting.PaymentMethod do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
