# Workflow: cashmove_management — 资金流水管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Lunch.LunchCashMove do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "午餐资金流水，双向记账（正数=充值/入账，负数=消费/扣款）"
  end

  postgres do
    table "lunch_cash_moves"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_cash_move

    queries do
      get :get_lunch_lunch_cash_move, :read
      list :list_lunch_lunch_cash_moves, :read
    end

    mutations do
      create :create_lunch_lunch_cash_move, :create
      destroy :delete_lunch_lunch_cash_move, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "金额：正数=充值（credit），负数=消费（debit）"
    end
    attribute :date, :date do
      allow_nil? false
      public? true
      description "流水日期"
    end
    attribute :description, :string do
      public? true
      description "流水描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :wallet_balance, :decimal, expr(sum_round(user.cash_moves, 2))
  end

  relationships do
    belongs_to :user, UniboExPoc.Lunch.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
