defmodule UniboV4.Expenses.ExpenseCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expense_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :expense_category

    queries do
      get :get_expense_category, :read
      list :list_expense_categorys, :read
    end

    mutations do
      create :create_expense_category, :create
      update :update_expense_category, :update
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

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :description]
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
