defmodule UniboV4.Sales.Quote do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Sales.Quote.Notifier]

  postgres do
    table "quotes"
    repo UniboV4.Repo
  end

  graphql do
    type :quote

    queries do
      get :get_quote, :read
      list :list_quotes, :read
    end

    mutations do
      create :create_quote, :create
      update :submit_quote, :submit
      update :accept_quote, :accept
      update :reject_quote, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quote_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :accepted, :rejected, :expired]
      default :draft
    end
    attribute :quote_date, :date, allow_nil?: false
    attribute :valid_thru_date, :date
    attribute :total_amount, :decimal
    attribute :currency, :string, default: "CNY"
    attribute :description, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Sales.QuoteItem
    belongs_to :customer, UniboV4.Sales.Customer do
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:quote_number, :quote_date, :valid_thru_date, :currency, :description, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:quote_number)
      change relate_actor(:created_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以发送"
      end
      change set_attribute(:status, :submitted)
    end
    update :accept do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已发送状态可以接受"
      end
      change set_attribute(:status, :accepted)
    end
    update :reject do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已发送状态可以拒绝"
      end
      change set_attribute(:status, :rejected)
    end
  end

  identities do
    identity :unique_quote_number, [:quote_number]
  end

end
