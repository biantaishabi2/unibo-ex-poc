# Workflow: config_floor_link — POS 配置-楼层关联管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.POS.PosConfigFloor do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_config_floors"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :config, UniboV4.POS.PosConfig do
      public? true
      allow_nil? false
    end
    belongs_to :floor, UniboV4.POS.RestaurantFloor do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept []
      argument :config_id, :uuid, allow_nil?: false
      argument :floor_id, :uuid, allow_nil?: false
      change manage_relationship(:config_id, :config, type: :append, on_lookup: :relate)
      change manage_relationship(:floor_id, :floor, type: :append, on_lookup: :relate)
      validate present(:config_id)
      validate present(:floor_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_config_floor, [:config_id, :floor_id]
  end

end
