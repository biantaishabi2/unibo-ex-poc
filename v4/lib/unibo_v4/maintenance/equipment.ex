defmodule UniboV4.Maintenance.Equipment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "equipments"
    repo UniboV4.Repo
  end

  graphql do
    type :equipment

    queries do
      get :get_equipment, :read
      list :list_equipments, :read
    end

    mutations do
      create :create_equipment, :create
      update :update_equipment, :update
      update :retire_equipment, :retire
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :asset_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:operational, :maintenance, :retired]
      default :operational
    end
    attribute :category, :string
    attribute :location, :string
    attribute :purchase_date, :date
    attribute :warranty_expiry_date, :date
    attribute :serial_number, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboV4.Maintenance.MaintenanceRequest
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:asset_code, :name, :category, :location, :purchase_date, :warranty_expiry_date, :serial_number, :notes]
      validate present(:asset_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :status, :category, :location, :notes]
    end
    update :retire do
      accept []
      validate attribute_in(:status, [:operational, :maintenance]) do
        message "只有运行中或维护中状态可以报废"
      end
      change set_attribute(:status, :retired)
    end
  end

  identities do
    identity :unique_asset_code, [:asset_code]
  end

end
