# Workflow: eco_type_maintain_flow — ECO 类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.PLM.EcoType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "ECO 类型，定义工程变更单的分类及可用阶段集合"
  end

  postgres do
    table "plm_eco_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_eco_type

    queries do
      get :get_plm_eco_type, :read
      list :list_plm_eco_types, :read
    end

    mutations do
      create :create_plm_eco_type, :create
      update :update_plm_eco_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称（新品导入 / 产品改进 / 法规合规 / 纠正措施 / 成本优化）"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序序号"
    end
    attribute :alias_id, :uuid do
      public? true
      description "邮件别名ID（自动创建ECO）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :stage_ids, UniboExPoc.PLM.EcoStage do
      public? true
      through UniboExPoc.PLM.EcoTypeStageLink
    end
    has_many :ecos, UniboExPoc.PLM.Eco do
      public? true
      destination_attribute :type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :alias_id]
      validate present(:name)
      validate compare(:stage_ids, greater_than: 0)
      # message: "每个ECO类型必须关联至少一个阶段"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :alias_id]
      # skipped: validate compare :stage_ids (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_eco_type_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
