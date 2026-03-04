# Workflow: sign_role_write_flow — 签名角色写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Sign.SignRole do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sign_roles"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :color, :string, public?: true
    attribute :is_default, :boolean do
      default false
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :color, :is_default]
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
      accept [:name, :color, :is_default]
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

  identities do
    identity :unique_role_name, [:name]
  end

end
