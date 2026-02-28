defmodule UniboV4.HR.LeaveType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "leave_types"
    repo UniboV4.Repo
  end

  graphql do
    type :leave_type

    queries do
      get :get_leave_type, :read
      list :list_leave_types, :read
    end

    mutations do
      create :create_leave_type, :create
      update :update_leave_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :code, :string, allow_nil?: false
    attribute :max_days_per_year, :decimal
    attribute :is_paid, :boolean, default: true
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :max_days_per_year, :is_paid, :description]
      validate present(:name)
      validate present(:code)
    end
    update :update do
      primary? true
      accept [:name, :max_days_per_year, :is_paid, :description]
    end
  end

  identities do
    identity :unique_leave_type_code, [:code]
  end

end
