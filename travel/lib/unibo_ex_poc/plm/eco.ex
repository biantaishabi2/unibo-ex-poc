# Workflow: eco_lifecycle — ECO 全生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> advance_stage
#   advance_stage --> advance_stage
#   advance_stage --> apply_changes
#   advance_stage --> rebase
#   apply_changes --> [*] : changes_applied
#   rebase --> advance_stage
# ```
defmodule UniboExPoc.PLM.Eco do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.PLM.Eco.Notifier]

  resource do
    description "工程变更单，使用阶段（Stage）驱动的看板式状态机管理 BOM 变更"
  end

  postgres do
    table "plm_ecos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_eco

    queries do
      get :get_plm_eco, :read
      list :list_plm_ecos, :read
    end

    mutations do
      create :create_plm_eco, :create
      update :update_plm_eco, :update
      update :advance_stage_plm_eco, :advance_stage
      update :apply_changes_plm_eco, :apply_changes
      update :rebase_plm_eco, :rebase
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "ECO 编号/名称（自动编号）"
    end
    attribute :bom_revision, :integer do
      public? true
      description "BOM 版本号（基准+1）"
    end
    attribute :effectivity_date, :utc_datetime do
      public? true
      description "生效日期（应用变更时写入）"
    end
    attribute :note, :string do
      public? true
      description "变更说明（支持富文本）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :kanban_state, :atom, {UniboExPoc.PLM.Calculations.Eco.KanbanState, []}
    calculate :is_conflict, :boolean, {UniboExPoc.PLM.Calculations.Eco.IsConflict, []}
    calculate :allow_apply, :boolean, {UniboExPoc.PLM.Calculations.Eco.AllowApply, []}
    calculate :bom_change_ids, {:array, :string}, {UniboExPoc.PLM.Calculations.Eco.BomChangeIds, []}
  end

  relationships do
    belongs_to :type, UniboExPoc.PLM.EcoType do
      public? true
      allow_nil? false
    end
    belongs_to :stage, UniboExPoc.PLM.EcoStage do
      public? true
      allow_nil? false
    end
    belongs_to :product_tmpl, UniboExPoc.PLM.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :bom, UniboExPoc.PLM.MrpBom do
      public? true
      allow_nil? false
    end
    belongs_to :new_bom, UniboExPoc.PLM.MrpBom do
      public? true
    end
    belongs_to :responsible, UniboExPoc.PLM.Party do
      public? true
      allow_nil? false
      source_attribute :responsible_party_id
    end
    many_to_many :tag_ids, UniboExPoc.PLM.EcoTag do
      public? true
      through UniboExPoc.PLM.EcoTagLink
    end
    has_many :approval_ids, UniboExPoc.PLM.EcoApproval do
      public? true
      destination_attribute :eco_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "创建 ECO，自动复制基准 BOM 为修订副本"
      primary? true
      accept [:name, :note]
      argument :type_id, :uuid, allow_nil?: false
      argument :product_tmpl_id, :uuid, allow_nil?: false
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:type_id, :type, type: :append, on_lookup: :relate)
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      change manage_relationship(:product_tmpl_id, :product_tmpl, type: :append, on_lookup: :relate)
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
      argument :responsible_id, :uuid, allow_nil?: false
      change manage_relationship(:responsible_id, :responsible, type: :append, on_lookup: :relate)
      validate present(:name)
      change UniboExPoc.PLM.Changes.Eco.CreateCall1
      change UniboExPoc.PLM.Changes.Eco.CreateCall2
      change relate_actor(:responsible)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :note]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :advance_stage do
      description "推进到下一阶段（含审批模板的阶段自动创建审批记录）"
      argument :target_stage_id, :uuid, allow_nil?: false
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.PLM.Changes.Eco.AdvanceStageCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :apply_changes do
      description "应用变更到生产 BOM（归档旧BOM、激活新BOM、写入生效日期）"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.PLM.Changes.Eco.ApplyChangesCall5
      change UniboExPoc.PLM.Changes.Eco.ApplyChangesCall6
      change UniboExPoc.PLM.Changes.Eco.ApplyChangesCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :rebase do
      description "同步最新生产 BOM，重新计算差异，清除冲突标记"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.PLM.Changes.Eco.RebaseCall8
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
