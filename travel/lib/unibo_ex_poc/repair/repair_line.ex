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
defmodule UniboExPoc.Repair.RepairLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "维修明细行，记录使用零件和工时，对应 OFBiz ReturnItem 扩展"
  end

  postgres do
    table "repair_lines"
    repo UniboExPoc.Repo
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
      description "明细类型（零件/工时/其他）"
    end
    attribute :description, :string do
      allow_nil? false
      public? true
      description "零件名称或工时描述"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      default 1
      public? true
      description "零件数量或工时小时数"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "单价（零件单价或工时费率）"
    end
    attribute :part_cost, :decimal do
      public? true
      description "零件费（quantity * unit_price when line_type == part）"
    end
    attribute :labor_cost, :decimal do
      public? true
      description "工时费（quantity * unit_price when line_type == labor）"
    end
    attribute :warranty_covered, :boolean do
      default false
      public? true
      description "该行是否由保修覆盖（不计费）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :repair_ticket, UniboExPoc.Repair.RepairTicket do
      public? true
      allow_nil? false
    end
    belongs_to :warranty, UniboExPoc.Repair.Warranty do
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
      # WARNING: compare :quantity 参数无法识别，请检查 YAML 定义
      # WARNING: compare :unit_price 参数无法识别，请检查 YAML 定义
      validate attribute_in(:state, [:draft, :confirmed, :under_repair])
      # message: "工单状态为 draft/confirmed/under_repair 时才允许编辑明细行"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :quantity, :unit_price, :warranty_covered]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
      # skipped: validate compare :unit_price (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :confirmed, :under_repair] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :confirmed, :under_repair]}))
        end
      end
      # message: "工单状态为 draft/confirmed/under_repair 时才允许编辑明细行"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
