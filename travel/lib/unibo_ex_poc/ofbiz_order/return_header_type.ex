defmodule UniboExPoc.Ofbiz.Order.ReturnHeaderType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_return_header_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_return_header_type

    queries do
      get :get_ofbiz_order_return_header_type, :read
      list :list_ofbiz_order_return_header_types, :read
    end

    mutations do
      create :create_ofbiz_order_return_header_type, :create
      update :update_ofbiz_order_return_header_type, :update
      destroy :delete_ofbiz_order_return_header_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_header_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_return_header_type, UniboExPoc.Ofbiz.Order.ReturnHeaderType do
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
