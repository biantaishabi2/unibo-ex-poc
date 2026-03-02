defmodule UniboV4.Expenses.ExpenseLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expense_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :expense_line

    mutations do
      create :create_expense_line, :create
      update :update_expense_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :amount, :decimal, allow_nil?: false, public?: true
    attribute :expense_date, :date, allow_nil?: false, public?: true
    attribute :receipt_reference, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :report, UniboV4.Expenses.ExpenseReport do
      allow_nil? false
        public? true
    end
    belongs_to :category, UniboV4.Expenses.ExpenseCategory, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :amount, :expense_date, :receipt_reference, :notes]
      argument :category_id, :uuid
      argument :report_id, :uuid, allow_nil?: false
      change manage_relationship(:report_id, :report, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:description, :amount, :expense_date, :receipt_reference, :notes]
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

end
