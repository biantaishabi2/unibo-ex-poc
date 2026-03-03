defmodule UniboV4.POS.FiscalPosition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_fiscal_positions"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_fiscal_position

    queries do
      get :get_pos_fiscal_position, :read
      list :list_pos_fiscal_positions, :read
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
