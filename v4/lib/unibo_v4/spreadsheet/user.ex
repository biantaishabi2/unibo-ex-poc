defmodule UniboV4.Spreadsheet.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "spreadsheet_users"
    repo UniboV4.Repo
  end

  graphql do
    type :spreadsheet_user

    queries do
      get :get_spreadsheet_user, :read
      list :list_spreadsheet_users, :read
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
