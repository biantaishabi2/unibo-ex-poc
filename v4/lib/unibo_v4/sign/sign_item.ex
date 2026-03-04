# Workflow: sign_item_write_flow — 签名字段写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Sign.SignItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sign_items"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:signature, :initial, :text, :date, :checkbox, :selection]
      public? true
    end
    attribute :page, :integer do
      allow_nil? false
      public? true
    end
    attribute :pos_x, :float do
      allow_nil? false
      public? true
    end
    attribute :pos_y, :float do
      allow_nil? false
      public? true
    end
    attribute :width, :float do
      allow_nil? false
      public? true
    end
    attribute :height, :float do
      allow_nil? false
      public? true
    end
    attribute :required, :boolean do
      default false
      public? true
    end
    attribute :placeholder, :string, public?: true
  end

  relationships do
    belongs_to :template, UniboV4.Sign.SignTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :role, UniboV4.Sign.SignRole do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:destroy]
    create :create do
      primary? true
      accept [:type, :page, :pos_x, :pos_y, :width, :height, :required, :placeholder]
      argument :template_id, :uuid, allow_nil?: false
      argument :role_id, :uuid, allow_nil?: false
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      change manage_relationship(:role_id, :role, type: :append, on_lookup: :relate)
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
      accept [:type, :page, :pos_x, :pos_y, :width, :height, :required, :placeholder]
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
  end

  validations do
    validate compare(:page, greater_than: 0)
    validate compare(:pos_x, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    validate compare(:pos_y, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    validate compare(:width, greater_than: 0)
    validate compare(:height, greater_than: 0)
  end

end
