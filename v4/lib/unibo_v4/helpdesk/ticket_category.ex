defmodule UniboV4.Helpdesk.TicketCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ticket_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :ticket_category

    queries do
      get :get_ticket_category, :read
      list :list_ticket_categorys, :read
    end

    mutations do
      create :create_ticket_category, :create
      update :update_ticket_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :code, :string, allow_nil?: false
    attribute :description, :string
    attribute :is_active, :boolean, default: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, UniboV4.Helpdesk.TicketCategory
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :description]
      argument :parent_id, :uuid
      validate present(:name)
      validate present(:code)
    end
    update :update do
      primary? true
      accept [:name, :description, :is_active]
    end
  end

  identities do
    identity :unique_category_code, [:code]
  end

end
