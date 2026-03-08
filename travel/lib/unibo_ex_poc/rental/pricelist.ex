defmodule UniboExPoc.Rental.Pricelist do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域价格表占位实体"
  end

  postgres do
    table "rental_pricelists"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rental_pricelist

    queries do
      get :get_rental_pricelist, :read
      list :list_rental_pricelists, :read
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
