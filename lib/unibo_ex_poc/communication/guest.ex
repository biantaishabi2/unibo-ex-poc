defmodule UniboExPoc.Communication.Guest do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域访客占位实体"
  end

  postgres do
    table "communication_guests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_guest

    queries do
      get :get_communication_guest, :read
      list :list_communication_guests, :read
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
