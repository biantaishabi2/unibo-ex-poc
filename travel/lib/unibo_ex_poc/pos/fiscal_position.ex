defmodule UniboExPoc.POS.FiscalPosition do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "财务位置占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "pos_fiscal_positions"
    repo UniboExPoc.Repo
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
