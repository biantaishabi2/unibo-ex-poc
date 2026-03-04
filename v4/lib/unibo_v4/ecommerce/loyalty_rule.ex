# Workflow: rule_lifecycle — 积分规则管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.LoyaltyRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_loyalty_rules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :minimum_qty, :integer do
      default 0
      public? true
    end
    attribute :minimum_amount, :decimal do
      default 0
      public? true
    end
    attribute :reward_point_amount, :decimal do
      default 1
      public? true
    end
    attribute :reward_point_mode, :atom do
      constraints one_of: [:order, :money, :unit]
      default :order
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboV4.Ecommerce.LoyaltyProgram do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:code, :minimum_qty, :minimum_amount, :reward_point_amount, :reward_point_mode]
      argument :program_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
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
    update :update do
      primary? true
      accept [:code, :minimum_qty, :minimum_amount, :reward_point_amount, :reward_point_mode]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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

end
