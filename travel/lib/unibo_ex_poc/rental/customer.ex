defmodule UniboExPoc.Rental.Customer do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域客户占位实体"
  end

  postgres do
    table "rental_customers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rental_customer

    queries do
      get :get_rental_customer, :read
      list :list_rental_customers, :read
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
