# Workflow: material_line_management — 物料使用行管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Helpdesk.FsmMaterialLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "现场服务物料使用行，记录每次任务使用的物料和数量"
  end

  postgres do
    table "helpdesk_fsm_material_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_fsm_material_line

    queries do
      get :get_helpdesk_fsm_material_line, :read
      list :list_helpdesk_fsm_material_lines, :read
    end

    mutations do
      create :create_helpdesk_fsm_material_line, :create
      update :update_helpdesk_fsm_material_line, :update
      destroy :delete_helpdesk_fsm_material_line, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "使用数量"
    end
    attribute :description, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :service_order, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.Helpdesk.Product do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:quantity, :description]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      validate present(:quantity)
      # message: "使用数量必填"
      validate compare(:quantity, greater_than: 0)
      # message: "使用数量必须大于 0"
      validate present(:service_order)
      # message: "必须关联现场服务任务"
      validate present(:product)
      # message: "必须指定产品"
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
      accept [:quantity, :description]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
