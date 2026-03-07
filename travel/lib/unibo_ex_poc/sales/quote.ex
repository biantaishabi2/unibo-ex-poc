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
defmodule UniboExPoc.Sales.Quote do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Sales.Quote.Notifier]

  resource do
    description "销售报价单"
  end

  postgres do
    table "sales_quotes"
    repo UniboExPoc.Repo
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
      description "报价单号"
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
    attribute :valid_thru_date, :date do
      public? true
      description "有效期至"
    end
    attribute :total_amount, :decimal do
      public? true
      description "报价总金额"
    end
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
    has_many :items, UniboExPoc.Sales.QuoteItem do
      public? true
    end
    belongs_to :customer, UniboExPoc.Sales.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboExPoc.Sales.User do
      public? true
    end
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
      change UniboExPoc.Sales.Changes.Quote.ComputeTotalAmount
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
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
    update :submit do
      description "发送报价"
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
      description "客户接受报价"
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
      description "客户拒绝报价"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
