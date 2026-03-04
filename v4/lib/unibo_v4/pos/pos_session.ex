# Workflow: session_lifecycle — POS 会话生命周期（opening→open→closing→closed）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> open
#   open --> start_close
#   start_close --> close
#   close --> [*]
# ```
defmodule UniboV4.POS.PosSession do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_sessions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :session_code, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:opening, :open, :closing, :closed]
      default :opening
      public? true
    end
    attribute :opening_balance, :decimal do
      default 0
      public? true
    end
    attribute :closing_balance_counted, :decimal, public?: true
    attribute :closing_balance_theoretical, :decimal, public?: true
    attribute :cash_difference, :decimal, public?: true
    attribute :open_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :close_date, :utc_datetime, public?: true
    attribute :rescue, :boolean do
      default false
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :orders, UniboV4.POS.PosOrder do
      public? true
      destination_attribute :session_id
    end
    belongs_to :cashier, UniboV4.POS.User do
      public? true
    end
    belongs_to :config, UniboV4.POS.PosConfig do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:session_code, :opening_balance, :open_date, :rescue, :notes]
      validate present(:session_code)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:opening_balance]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      # TODO: 跨实体聚合表达式暂不支持
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :closed)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
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
  end

  identities do
    identity :unique_session_code, [:session_code]
  end

end
