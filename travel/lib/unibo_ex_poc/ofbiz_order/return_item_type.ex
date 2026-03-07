defmodule UniboExPoc.Ofbiz.Order.ReturnItemType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "ReturnItemType记录ReturnItem的类型"
  end

  postgres do
    table "order_return_item_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_return_item_type

    queries do
      get :get_order_return_item_type, :read
      list :list_order_return_item_types, :read
    end

    mutations do
      create :create_order_return_item_type, :create
      update :update_order_return_item_type, :update
      destroy :delete_order_return_item_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_item_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_return_item_type, UniboExPoc.Ofbiz.Order.ReturnItemType do
      public? true
      source_attribute :parent_type_id
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
