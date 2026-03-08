# Workflow: repair_tag_maintain_flow — 标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Repair.RepairTag do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "维修工单标签，用于分类（如：液晶屏、主板、电池、外壳、水损、保修件）"
  end

  postgres do
    table "repair_tags"
    repo UniboExPoc.Repo
  end

  graphql do
    type :repair_repair_tag

    queries do
      get :get_repair_repair_tag, :read
      list :list_repair_repair_tags, :read
    end

    mutations do
      create :create_repair_repair_tag, :create
      update :update_repair_repair_tag, :update
      destroy :delete_repair_repair_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称"
    end
    attribute :color, :integer do
      default 0
      public? true
      description "标签颜色索引（0-11，用于看板着色）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :color]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :color]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_tag_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
