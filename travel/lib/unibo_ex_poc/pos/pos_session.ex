# Workflow: session_lifecycle — POS 会话生命周期（opening→open→closing→closed）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> open
#   open --> start_close
#   start_close --> close
#   close --> [*]
# ```
defmodule UniboExPoc.POS.PosSession do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "POS 会话，管理收银台从开启到关闭的完整生命周期"
  end

  postgres do
    table "pos_sessions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_pos_session

    queries do
      get :get_pos_pos_session, :read
      list :list_pos_pos_sessions, :read
    end

    mutations do
      create :create_pos_pos_session, :create
      update :open_pos_pos_session, :open
      update :start_close_pos_pos_session, :start_close
      update :close_pos_pos_session, :close
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :session_code, :string do
      allow_nil? false
      public? true
      description "会话编号，全局唯一"
    end
    attribute :status, :atom do
      constraints one_of: [:opening, :open, :closing, :closed]
      default :opening
      public? true
      description "会话状态"
    end
    attribute :opening_balance, :decimal do
      default 0
      public? true
      description "期初余额，从上一个 session 继承"
    end
    attribute :closing_balance_counted, :decimal do
      public? true
      description "实际盘点余额"
    end
    attribute :closing_balance_theoretical, :decimal do
      public? true
      description "理论余额 = opening_balance + sum(cash_statement_lines.amount)"
    end
    attribute :cash_difference, :decimal do
      public? true
      description "差异 = closing_balance_theoretical - closing_balance_counted"
    end
    attribute :open_date, :utc_datetime do
      allow_nil? false
      public? true
      description "开启时间"
    end
    attribute :close_date, :utc_datetime do
      public? true
      description "关闭时间"
    end
    attribute :rescue, :boolean do
      default false
      public? true
      description "是否救援会话（订单到达已关闭会话时自动创建）"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :orders, UniboExPoc.POS.PosOrder do
      public? true
      destination_attribute :session_id
    end
    belongs_to :cashier, UniboExPoc.POS.Party do
      public? true
      source_attribute :cashier_party_id
    end
    belongs_to :config, UniboExPoc.POS.PosConfig do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:session_code, :config_id, :opening_balance, :open_date, :rescue, :notes]
      validate present(:session_code)
      validate present(:)
      # message: "每个终端同一时刻最多一个非救援的活跃会话"
      # validation: after_lock_date — 开启日期必须晚于公司会计锁定日期
      change relate_actor(:cashier)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :open do
      description "打开会话，期初余额默认继承同 config 上一个 closed 会话的 closing_balance_counted"
      primary? true
      accept [:opening_balance]
      # skipped: validate present : (incompatible with bulk update atomic path)
      # skipped: validate custom :open_date (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :opening do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :opening}))
        end
      end
      # message: "只有开启中状态可以打开"
      change UniboExPoc.POS.Changes.PosSession.ComputeOpeningBalance
      change set_attribute(:status, :open)
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
    update :start_close do
      description "开始关闭会话（进入 closing 状态）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :open do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :open}))
        end
      end
      # message: "只有已打开状态可以开始关闭"
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:status, :closing)
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
    update :close do
      description "关闭会话，触发会计分录、对账、库存拣货"
      accept [:closing_balance_counted]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :closing do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :closing}))
        end
      end
      # message: "只有关闭中状态可以关闭"
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:status, :closed)
      change UniboExPoc.POS.Changes.PosSession.ComputeCloseDate
      change UniboExPoc.POS.Changes.PosSession.CloseCall7
      change UniboExPoc.POS.Changes.PosSession.CloseCall8
      change UniboExPoc.POS.Changes.PosSession.CloseCall9
      change UniboExPoc.POS.Changes.PosSession.CloseCall10
      change UniboExPoc.POS.Changes.PosSession.CloseCall11
      change UniboExPoc.POS.Changes.PosSession.CloseCall12
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
    identity :unique_session_code, [:session_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
