# Workflow: warranty_maintain_flow — 保修记录维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Repair.Warranty do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "产品保修记录，用于在创建 RepairTicket 时自动校验是否适用保修"
  end

  postgres do
    table "repair_warranties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :repair_warranty

    queries do
      get :get_repair_warranty, :read
      list :list_repair_warrantys, :read
    end

    mutations do
      create :create_repair_warranty, :create
      update :update_repair_warranty, :update
      destroy :delete_repair_warranty, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :warranty_number, :string do
      allow_nil? false
      public? true
      description "保修单编号"
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "保修开始日期（通常为销售日期）"
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
      description "保修到期日期"
    end
    attribute :warranty_type, :atom do
      allow_nil? false
      constraints one_of: [:manufacturer, :extended, :on_site, :carry_in]
      public? true
      description "保修类型（厂商/延保/上门/送修）"
    end
    attribute :terms, :string do
      public? true
      description "保修条款说明"
    end
    attribute :is_active, :boolean do
      public? true
      description "是否在有效保修期内"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:warranty_number, :start_date, :end_date, :warranty_type, :terms]
      argument :customer_id, :uuid, allow_nil?: false
      argument :product_id, :uuid, allow_nil?: false
      argument :sales_order_id, :uuid
      validate present(:warranty_number)
      # WARNING: compare :end_date 参数无法识别，请检查 YAML 定义
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:end_date, :terms]
      # skipped: validate compare :end_date (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_warranty_number, [:warranty_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
