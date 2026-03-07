defmodule UniboExPoc.Ofbiz.Order.OrderTerm do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_terms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_term

    queries do
      get :get_order_order_term, :read
      list :list_order_order_terms, :read
    end

    mutations do
      create :create_order_order_term, :create
      update :update_order_order_term, :update
      destroy :delete_order_order_term, :destroy
    end

  end

  attributes do
    attribute :term_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :term_value, :decimal, public?: true
    attribute :term_days, :integer, public?: true
    attribute :text_value, :string, public?: true
    attribute :description, :string, public?: true
    attribute :uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
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
