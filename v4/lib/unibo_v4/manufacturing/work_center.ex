defmodule UniboV4.Manufacturing.WorkCenter do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "work_centers"
    repo UniboV4.Repo
  end

  graphql do
    type :work_center

    queries do
      get :get_work_center, :read
      list :list_work_centers, :read
    end

    mutations do
      create :create_work_center, :create
      update :update_work_center, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :center_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :capacity, :decimal
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :maintenance]
      default :active
    end
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:center_code, :name, :capacity, :description]
      validate present(:center_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :capacity, :status, :description]
    end
  end

  identities do
    identity :unique_center_code, [:center_code]
  end

end
