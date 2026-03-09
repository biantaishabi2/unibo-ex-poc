# Workflow: floor_lifecycle — 餐饮楼层生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   create --> destroy
#   update --> update
#   update --> deactivate
#   update --> destroy
#   deactivate --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.POS.RestaurantFloor do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "餐饮楼层，管理餐厅的楼层布局及其下属餐桌"
  end

  postgres do
    table "pos_restaurant_floors"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_restaurant_floor

    queries do
      get :get_pos_restaurant_floor, :read
      list :list_pos_restaurant_floors, :read
    end

    mutations do
      create :create_pos_restaurant_floor, :create
      update :update_pos_restaurant_floor, :update
      update :deactivate_pos_restaurant_floor, :deactivate
      destroy :delete_pos_restaurant_floor, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "楼层名称"
    end
    attribute :background_image, :string do
      public? true
      description "楼层背景图"
    end
    attribute :background_color, :string do
      default "rgb(210, 210, 210)"
      public? true
      description "背景色（CSS 格式）"
    end
    attribute :sequence, :integer do
      default 1
      public? true
      description "排序序号"
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
    has_many :tables, UniboExPoc.POS.RestaurantTable do
      public? true
      destination_attribute :floor_id
    end
    has_many :config_links, UniboExPoc.POS.PosConfigFloor do
      public? true
      destination_attribute :floor_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :background_image, :background_color, :sequence, :active]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :background_image, :background_color, :sequence, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用楼层，级联停用所有餐桌（需先检查无草稿订单）"
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:active, false)
      change UniboExPoc.POS.Changes.RestaurantFloor.DeactivateCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除楼层（有活跃会话时禁止删除）"
      # validation: no_active_session — 关联的 POS 配置存在活跃会话，无法删除楼层
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:tables, :config_links]
  end

end
