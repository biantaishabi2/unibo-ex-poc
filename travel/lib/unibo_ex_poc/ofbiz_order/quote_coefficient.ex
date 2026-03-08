defmodule UniboExPoc.Ofbiz.Order.QuoteCoefficient do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_quote_coefficients"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_quote_coefficient

    queries do
      get :get_order_quote_coefficient, :read
      list :list_order_quote_coefficients, :read
    end

    mutations do
      create :create_order_quote_coefficient, :create
      update :update_order_quote_coefficient, :update
      destroy :delete_order_quote_coefficient, :destroy
    end

  end

  attributes do
    attribute :coeff_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :coeff_value, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quote, UniboExPoc.Ofbiz.Order.Quote do
      public? true
      attribute_type :string
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
