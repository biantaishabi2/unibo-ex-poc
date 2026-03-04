# Workflow: requisition_type_lifecycle — 采购申请类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseRequisitionType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_purchase_requisition_types"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string do
      allow_nil? false
      public? true
    end
    attribute :has_table, :boolean do
      default false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :exclusive, :atom do
      constraints one_of: [:exclusive, :multiple]
      default :multiple
      public? true
    end
    attribute :quantity_copy, :atom do
      constraints one_of: [:copy, :none]
      default :copy
      public? true
    end
    attribute :line_copy, :atom do
      constraints one_of: [:copy, :none]
      default :copy
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent_type, UniboV4.Purchasing.PurchaseRequisitionType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence, :exclusive, :quantity_copy, :line_copy, :active, :has_table]
      validate present(:name)
      validate present(:description)
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
    update :update do
      primary? true
      accept [:name, :description, :sequence, :exclusive, :quantity_copy, :line_copy, :active, :has_table]
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

end
