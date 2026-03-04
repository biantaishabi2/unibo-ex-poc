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
defmodule UniboV4.POS.RestaurantFloor do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_restaurant_floors"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :background_image, :string, public?: true
    attribute :background_color, :string do
      default "rgb(210, 210, 210)"
      public? true
    end
    attribute :sequence, :integer do
      default 1
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tables, UniboV4.POS.RestaurantTable do
      public? true
      destination_attribute :floor_id
    end
    has_many :config_links, UniboV4.POS.PosConfigFloor do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :background_image, :background_color, :sequence, :active]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :deactivate do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:active, false)
      # TODO: 不支持的 change effect side_effect
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    destroy :destroy do
      # TODO: 不支持的 action 内校验规则 custom
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

end
