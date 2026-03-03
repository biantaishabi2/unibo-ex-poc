# Workflow: quote_lifecycle — 报价单生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> submit
#   submit --> accept
#   submit --> reject
#   accept --> [*] : accepted
#   reject --> [*]
# ```
defmodule UniboV4.Sales.Quote do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Sales.Quote.Notifier]

  postgres do
    table "sales_quotes"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_quote

    queries do
      get :get_sales_quote, :read
      list :list_sales_quotes, :read
      get :get_list_sales_quote, :list
      list :list_list_sales_quotes, :list
      get :get_search_sales_quote, :search
      list :list_search_sales_quotes, :search
      get :get_get_sales_quote, :get
      list :list_get_sales_quotes, :get
      get :get_preview_sales_quote, :preview
      list :list_preview_sales_quotes, :preview
      get :get_compute_sales_quote, :compute
      list :list_compute_sales_quotes, :compute
      get :get_lookup_sales_quote, :lookup
      list :list_lookup_sales_quotes, :lookup
    end

    mutations do
      create :create_sales_quote, :create
      update :submit_sales_quote, :submit
      update :accept_sales_quote, :accept
      update :reject_sales_quote, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quote_number, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :accepted, :rejected, :expired]
      default :draft
      public? true
    end
    attribute :quote_date, :date do
      allow_nil? false
      public? true
    end
    attribute :valid_thru_date, :date, public?: true
    attribute :total_amount, :decimal, public?: true
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Sales.QuoteItem do
      public? true
    end
    belongs_to :customer, UniboV4.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Sales.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:quote_number, :quote_date, :valid_thru_date, :currency, :description, :notes]
      argument :items, {:array, :map}, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:quote_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :submit do
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送"
      change set_attribute(:status, :submitted)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :accept do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已发送状态可以接受"
      change set_attribute(:status, :accepted)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :reject do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已发送状态可以拒绝"
      change set_attribute(:status, :rejected)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_quote_number, [:quote_number]
  end

end
