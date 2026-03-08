# Workflow: config_floor_link — POS 配置-楼层关联管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.POS.PosConfigFloor do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "POS 配置与餐饮楼层的多对多关联表"
  end

  postgres do
    table "pos_config_floors"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_pos_config_floor

    queries do
      get :get_pos_pos_config_floor, :read
      list :list_pos_pos_config_floors, :read
    end

    mutations do
      create :create_pos_pos_config_floor, :create
      destroy :delete_pos_pos_config_floor, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :config, UniboExPoc.POS.PosConfig do
      public? true
      allow_nil? false
    end
    belongs_to :floor, UniboExPoc.POS.RestaurantFloor do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept []
      argument :config_id, :uuid, allow_nil?: false
      argument :floor_id, :uuid, allow_nil?: false
      change manage_relationship(:config_id, :config, type: :append, on_lookup: :relate)
      change manage_relationship(:floor_id, :floor, type: :append, on_lookup: :relate)
      validate present(:config_id)
      validate present(:floor_id)
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_config_floor, [:config_id, :floor_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
