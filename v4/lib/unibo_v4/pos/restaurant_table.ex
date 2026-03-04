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
defmodule UniboV4.POS.RestaurantTable do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_restaurant_tables"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :shape, :atom do
      constraints one_of: [:square, :round]
      default :square
      public? true
    end
    attribute :seats, :integer do
      default 1
      public? true
    end
    attribute :position_h, :decimal do
      default 10
      public? true
    end
    attribute :position_v, :decimal do
      default 10
      public? true
    end
    attribute :width, :decimal do
      default 50
      public? true
    end
    attribute :height, :decimal do
      default 50
      public? true
    end
    attribute :color, :string do
      default "#35D374"
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
    belongs_to :floor, UniboV4.POS.RestaurantFloor do
      public? true
      allow_nil? false
    end
    has_many :orders, UniboV4.POS.PosOrder do
      public? true
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
      accept [:name, :shape, :seats, :position_h, :position_v, :width, :height, :color, :active]
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

  validations do
    validate compare(:seats, greater_than_or_equal_to: 1)
  end

end
