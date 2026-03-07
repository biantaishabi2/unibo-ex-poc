defmodule UniboExPoc.Ofbiz.Product.Container do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_containers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_container

    queries do
      get :get_product_container, :read
      list :list_product_containers, :read
    end

    mutations do
      create :create_product_container, :create
      update :update_product_container, :update
      destroy :delete_product_container, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :container_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :container_type, UniboExPoc.Ofbiz.Product.ContainerType do
      public? true
    end
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
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
