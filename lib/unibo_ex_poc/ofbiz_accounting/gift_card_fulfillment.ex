defmodule UniboV4.Ofbiz.Accounting.GiftCardFulfillment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gift_card_fulfillments"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gift_card_fulfillment

    queries do
      get :get_accounting_gift_card_fulfillment, :read
      list :list_accounting_gift_card_fulfillments, :read
    end

    mutations do
      create :create_accounting_gift_card_fulfillment, :create
      update :update_accounting_gift_card_fulfillment, :update
      destroy :delete_accounting_gift_card_fulfillment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fulfillment_id, :string, public?: true
    attribute :type_enum_id, :string, public?: true
    attribute :merchant_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :order_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :survey_response_id, :string, public?: true
    attribute :card_number, :string, public?: true
    attribute :pin_number, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :response_code, :string, public?: true
    attribute :reference_num, :string, public?: true
    attribute :auth_code, :string, public?: true
    attribute :fulfillment_date, :utc_datetime, public?: true
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
