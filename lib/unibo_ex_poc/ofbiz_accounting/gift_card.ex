defmodule UniboV4.Ofbiz.Accounting.GiftCard do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gift_cards"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_gift_card

    queries do
      get :get_accounting_gift_card, :read
      list :list_accounting_gift_cards, :read
    end

    mutations do
      create :create_accounting_gift_card, :create
      update :update_accounting_gift_card, :update
      destroy :delete_accounting_gift_card, :destroy
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
    belongs_to :payment_method, UniboV4.Ofbiz.Accounting.PaymentMethod do
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
