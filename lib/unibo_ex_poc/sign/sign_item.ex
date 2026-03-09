# Workflow: sign_item_write_flow — 签名字段写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Sign.SignItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "签名字段定义，描述 PDF 上需要填写的区域（推荐 JSONB/embeds_many 存储）"
  end

  postgres do
    table "sign_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_sign_item

    mutations do
      create :create_sign_sign_item, :create
      update :update_sign_sign_item, :update
      destroy :delete_sign_sign_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:signature, :initial, :text, :date, :checkbox, :selection]
      public? true
      description "字段类型"
    end
    attribute :page, :integer do
      allow_nil? false
      public? true
      description "PDF 页码"
    end
    attribute :pos_x, :float do
      allow_nil? false
      public? true
      description "X 坐标（百分比 0-100）"
    end
    attribute :pos_y, :float do
      allow_nil? false
      public? true
      description "Y 坐标（百分比 0-100）"
    end
    attribute :width, :float do
      allow_nil? false
      public? true
      description "宽度（百分比）"
    end
    attribute :height, :float do
      allow_nil? false
      public? true
      description "高度（百分比）"
    end
    attribute :required, :boolean do
      default false
      public? true
      description "是否必填"
    end
    attribute :placeholder, :string do
      public? true
      description "占位提示文字"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :template, UniboExPoc.Sign.SignTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :role, UniboExPoc.Sign.SignRole do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:type, :page, :pos_x, :pos_y, :width, :height, :required, :placeholder]
      argument :template_id, :uuid, allow_nil?: false
      argument :role_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:type, :page, :pos_x, :pos_y, :width, :height, :required, :placeholder, :role_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:page, greater_than: 0)
    validate compare(:pos_x, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    validate compare(:pos_y, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    validate compare(:width, greater_than: 0)
    validate compare(:height, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
