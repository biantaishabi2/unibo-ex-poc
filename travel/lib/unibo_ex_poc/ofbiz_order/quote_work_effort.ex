defmodule UniboExPoc.Ofbiz.Order.QuoteWorkEffort do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_quote_work_efforts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_quote_work_effort

    queries do
      get :get_order_quote_work_effort, :read
      list :list_order_quote_work_efforts, :read
    end

    mutations do
      create :create_order_quote_work_effort, :create
      update :update_order_quote_work_effort, :update
      destroy :delete_order_quote_work_effort, :destroy
    end

  end

  attributes do
    attribute :quote_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :work_effort_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quote, UniboExPoc.Ofbiz.Order.Quote do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
