defmodule UniboV4.Manufacturing.MrpSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "mrp_schedules"
    repo UniboV4.Repo
  end

  graphql do
    type :mrp_schedule

    queries do
      get :get_mrp_schedule, :read
      list :list_mrp_schedules, :read
    end

    mutations do
      create :create_mrp_schedule, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string, allow_nil?: false, public?: true
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:demand, :supply, :forecast]
        public? true
    end
    attribute :quantity, :decimal, allow_nil?: false, public?: true
    attribute :event_date, :date, allow_nil?: false, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :event_type, :quantity, :event_date, :description]
      validate present(:product_code)
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
  end

end
