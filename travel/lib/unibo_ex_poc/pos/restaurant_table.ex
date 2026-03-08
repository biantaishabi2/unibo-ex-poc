# Workflow: table_management — 餐桌管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.POS.RestaurantTable do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "餐桌，记录餐桌的布局位置、形状、座位数等信息"
  end

  postgres do
    table "pos_restaurant_tables"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_restaurant_table

    queries do
      get :get_pos_restaurant_table, :read
      list :list_pos_restaurant_tables, :read
    end

    mutations do
      create :create_pos_restaurant_table, :create
      update :update_pos_restaurant_table, :update
      destroy :delete_pos_restaurant_table, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "餐桌名称"
    end
    attribute :shape, :atom do
      constraints one_of: [:square, :round]
      default :square
      public? true
      description "餐桌形状"
    end
    attribute :seats, :integer do
      default 1
      public? true
      description "座位数"
    end
    attribute :position_h, :decimal do
      default 10
      public? true
      description "水平位置（像素）"
    end
    attribute :position_v, :decimal do
      default 10
      public? true
      description "垂直位置（像素）"
    end
    attribute :width, :decimal do
      default 50
      public? true
      description "宽度（像素）"
    end
    attribute :height, :decimal do
      default 50
      public? true
      description "高度（像素）"
    end
    attribute :color, :string do
      default "#35D374"
      public? true
      description "颜色（CSS 格式）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :floor, UniboExPoc.POS.RestaurantFloor do
      public? true
      allow_nil? false
    end
    has_many :orders, UniboExPoc.POS.PosOrder do
      public? true
      source_attribute :floor_id
      destination_attribute :table_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :shape, :seats, :position_h, :position_v, :width, :height, :color, :active]
      argument :floor_id, :uuid, allow_nil?: false
      change manage_relationship(:floor_id, :floor, type: :append, on_lookup: :relate)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :shape, :seats, :position_h, :position_v, :width, :height, :color, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除餐桌（有活跃会话时禁止删除）"
      # validation: no_active_session — 关联的 POS 配置存在活跃会话，无法删除餐桌
      change set_attribute(:id, expr(id))
    end
  end

  validations do
    validate compare(:seats, greater_than_or_equal_to: 1)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:orders]
  end

end
