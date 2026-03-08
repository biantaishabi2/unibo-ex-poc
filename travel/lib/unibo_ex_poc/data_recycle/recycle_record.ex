# Workflow: recycle_record_processing — 待回收记录处理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> validate
#   create --> discard
#   validate --> [*]
#   discard --> [*]
# ```
defmodule UniboExPoc.DataRecycle.RecycleRecord do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.DataRecycle,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "待回收记录——由回收规则扫描产生，等待人工确认或自动执行"
  end

  postgres do
    table "data_recycle_recycle_records"
    repo UniboExPoc.Repo
  end

  graphql do
    type :data_recycle_recycle_record

    queries do
      get :get_data_recycle_recycle_record, :read
      list :list_data_recycle_recycle_records, :read
    end

    mutations do
      create :create_data_recycle_recycle_record, :create
      update :validate_data_recycle_recycle_record, :validate
      update :discard_data_recycle_recycle_record, :discard
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :res_id, :integer do
      allow_nil? false
      public? true
      description "原始记录 ID"
    end
    attribute :res_model_name, :string do
      public? true
      description "原始记录所属模型名称"
    end
    attribute :name, :string do
      public? true
      description "原始记录的显示名称"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否活跃；忽略后设为 false"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :recycle_model, UniboExPoc.DataRecycle.RecycleModel do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:res_id, :res_model_name, :name, :active]
      argument :recycle_model_id, :uuid, allow_nil?: false
      change manage_relationship(:recycle_model_id, :recycle_model, type: :append, on_lookup: :relate)
      validate present(:res_id)
      change set_attribute(:id, expr(id))
    end
    update :validate do
      description "确认回收——执行归档或删除原始记录"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "仅活跃待回收记录可执行确认或忽略"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :discard do
      description "忽略——将 active 设为 false，不再显示"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "仅活跃待回收记录可执行确认或忽略"
      change set_attribute(:active, false)
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
