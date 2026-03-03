defmodule UniboV4.Delivery.FixedAsset do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_fixed_assets"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_fixed_asset

    queries do
      get :get_delivery_fixed_asset, :read
      list :list_delivery_fixed_assets, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
