defmodule UniboExPoc.Ofbiz.Product.GoodIdentification do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_good_identifications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_good_identification

    queries do
      get :get_product_good_identification, :read
      list :list_product_good_identifications, :read
    end

    mutations do
      create :create_product_good_identification, :create
      update :update_product_good_identification, :update
      destroy :delete_product_good_identification, :destroy
    end

  end

  attributes do
    attribute :good_identification_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :id_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :good_identification_type, UniboExPoc.Ofbiz.Product.GoodIdentificationType do
      public? true
      define_attribute? false
    end
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
