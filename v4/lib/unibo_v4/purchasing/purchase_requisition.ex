defmodule UniboV4.Purchasing.PurchaseRequisition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchase_requisitions"
    repo UniboV4.Repo
  end

  graphql do
    type :purchase_requisition

    queries do
      get :get_purchase_requisition, :read
      list :list_purchase_requisitions, :read
    end

    mutations do
      create :create_purchase_requisition, :create
      update :submit_purchase_requisition, :submit
      update :approve_purchase_requisition, :approve
      update :reject_purchase_requisition, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :requisition_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected, :cancelled]
      default :draft
    end
    attribute :description, :string
    attribute :required_by_date, :date
    attribute :total_estimated_amount, :decimal
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.Purchasing.PurchaseRequisitionItem
    belongs_to :requested_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:requisition_number, :description, :required_by_date, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      change manage_relationship(:items, :items, type: :create)
      validate present(:requisition_number)
      change relate_actor(:requested_by)
      # TODO: 跨实体聚合表达式暂不支持
    end
    update :submit do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以提交"
      end
      change set_attribute(:status, :submitted)
    end
    update :approve do
      accept []
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以审批"
      end
      change set_attribute(:status, :approved)
    end
    update :reject do
      argument :reason, :string, allow_nil?: false
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :submitted) do
        message "只有已提交状态可以驳回"
      end
      change set_attribute(:status, :rejected)
    end
  end

  identities do
    identity :unique_requisition_number, [:requisition_number]
  end

end
