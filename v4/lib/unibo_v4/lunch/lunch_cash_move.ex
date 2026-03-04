# Workflow: cashmove_management — 资金流水管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Lunch.LunchCashMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_cash_moves"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :date, :date do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :wallet_balance
  end

  relationships do
    belongs_to :user, UniboV4.Lunch.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:amount, :date, :description]
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:amount)
      validate present(:date)
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
