# Workflow: repair_line_maintain_flow — 维修明细维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Repair.Repair.RepairLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Repair.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "repair_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :repair_repair_line

    queries do
      get :get_repair_repair_line, :read
      list :list_repair_repair_lines, :read
    end

    mutations do
      create :create_repair_repair_line, :create
      update :update_repair_repair_line, :update
      destroy :delete_repair_repair_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :line_type, :atom do
      allow_nil? false
      constraints one_of: [:part, :labor, :other]
      public? true
    end
    attribute :description, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :part_cost, :decimal, public?: true
    attribute :labor_cost, :decimal, public?: true
    attribute :warranty_covered, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :repair_ticket, UniboV4.Repair.Repair.RepairTicket do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Repair.Repair.Product do
      public? true
    end
    belongs_to :technician, UniboV4.Repair.Repair.User do
      public? true
    end
    belongs_to :warranty, UniboV4.Repair.Repair.Warranty do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:line_type, :description, :quantity, :unit_price, :warranty_covered]
      argument :repair_ticket_id, :uuid, allow_nil?: false
      argument :product_id, :uuid
      argument :technician_id, :uuid
      change manage_relationship(:repair_ticket_id, :repair_ticket, type: :append, on_lookup: :relate)
      validate present(:description)
      # TODO: 不支持的 action 内校验规则 greater_than
      # TODO: 不支持的 action 内校验规则 greater_than_or_equal
      # TODO: 不支持的 action 内校验规则 repair_order_editable
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:description, :quantity, :unit_price, :warranty_covered]
      # skipped: validate greater_than :quantity (incompatible with bulk update atomic path)
      # skipped: validate greater_than_or_equal :unit_price (incompatible with bulk update atomic path)
      # skipped: validate repair_order_editable : (incompatible with bulk update atomic path)
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
