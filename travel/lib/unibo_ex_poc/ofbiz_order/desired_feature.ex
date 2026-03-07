defmodule UniboExPoc.Ofbiz.Order.DesiredFeature do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_desired_features"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_desired_feature

    queries do
      get :get_order_desired_feature, :read
      list :list_order_desired_features, :read
    end

    mutations do
      create :create_order_desired_feature, :create
      update :update_order_desired_feature, :update
      destroy :delete_order_desired_feature, :destroy
    end

  end

  attributes do
    attribute :desired_feature_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :requirement_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_feature_id, :string, public?: true
    attribute :optional_ind, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :requirement, UniboExPoc.Ofbiz.Order.Requirement do
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
