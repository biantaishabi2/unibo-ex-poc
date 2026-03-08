# Workflow: sign_role_write_flow — 签名角色写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Sign.SignRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "签名角色，用于区分不同签署方（如员工、HR 经理）"
  end

  postgres do
    table "sign_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_sign_role

    queries do
      get :get_sign_sign_role, :read
      list :list_sign_sign_roles, :read
    end

    mutations do
      create :create_sign_sign_role, :create
      update :update_sign_sign_role, :update
      destroy :delete_sign_sign_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "角色名称（如 Employee、HR Manager）"
    end
    attribute :color, :string do
      public? true
      description "UI 标识颜色"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "是否为默认角色"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
