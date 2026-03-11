defmodule UniboExPoc.Ofbiz.Accounting.GiftCard do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gift_cards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_gift_card

    queries do
      get :get_ofbiz_accounting_gift_card, :read
      list :list_ofbiz_accounting_gift_cards, :read
    end

    mutations do
      create :create_ofbiz_accounting_gift_card, :create
      update :update_ofbiz_accounting_gift_card, :update
      destroy :delete_ofbiz_accounting_gift_card, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :card_number, :string, public?: true
    attribute :pin_number, :string, public?: true
    attribute :expire_date, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
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
