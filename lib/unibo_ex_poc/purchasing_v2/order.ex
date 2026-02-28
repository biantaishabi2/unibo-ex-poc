defmodule UniboExPoc.PurchasingV2.Order do
  @moduledoc """
  V2 采购订单：应用层能力验证样例。

  覆盖能力：
  - Policy（create/read/update）
  - Notifier（submit/approve/reject）
  - Actor 透传（created_by_id）
  - 定制逻辑（供应商状态校验、加急审批、审批后日志、利润率计算）
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV2,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.PurchasingV2.OrderNotifier]

  require Ash.Query
  require Logger

  graphql do
    type(:order_v2)

    queries do
      get(:get_order_v2, :read)
      list(:list_orders_v2, :read)
    end

    mutations do
      create :create_order_v2, :create
      update(:update_order_v2, :update)
      update(:submit_order_v2, :submit)
      update(:approve_order_v2, :approve)
      update(:reject_order_v2, :reject)
      update(:emergency_approve_order_v2, :emergency_approve)
    end
  end

  postgres do
    table("v2_orders")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :order_name, :string do
      public?(true)
    end

    attribute :status, :atom do
      constraints(one_of: [:created, :submitted, :approved, :rejected])
      default(:created)
      allow_nil?(false)
      public?(true)
    end

    attribute :created_by_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    attribute :cost_amount, :decimal do
      default(Decimal.new(0))
      allow_nil?(false)
      public?(true)
    end

    attribute :sell_amount, :decimal do
      default(Decimal.new(0))
      allow_nil?(false)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to :supplier, UniboExPoc.PurchasingV2.Party do
      allow_nil?(false)
      public?(true)
    end

    has_many :items, UniboExPoc.PurchasingV2.OrderItem do
      public?(true)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:order_name, :cost_amount, :sell_amount])
      argument(:supplier_id, :uuid, allow_nil?: false)
      argument(:items, {:array, :map}, default: [])

      change(manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate))
      change(manage_relationship(:items, :items, type: :create))

      # Actor 管道：创建时落 created_by_id
      change(
        before_action(fn changeset, context ->
          with %{id: actor_id} <- Map.get(context, :actor),
               true <- is_binary(actor_id) and actor_id != "" do
            Ash.Changeset.force_change_attribute(changeset, :created_by_id, actor_id)
          else
            _ -> Ash.Changeset.add_error(changeset, field: :created_by_id, message: "actor.id 缺失")
          end
        end)
      )

      # 定制校验：供应商必须是 active
      change(
        before_action(fn changeset, _context ->
          supplier_id = Ash.Changeset.get_argument(changeset, :supplier_id)

          case Ash.get(UniboExPoc.PurchasingV2.Party, supplier_id, authorize?: false) do
            {:ok, %{status: :active}} ->
              changeset

            {:ok, _supplier} ->
              Ash.Changeset.add_error(changeset, field: :supplier_id, message: "供应商状态必须为 active")

            {:error, _error} ->
              Ash.Changeset.add_error(changeset, field: :supplier_id, message: "供应商不存在")
          end
        end)
      )
    end

    update :update do
      accept([:order_name, :cost_amount, :sell_amount])
    end

    update :submit do
      accept([])

      validate attribute_equals(:status, :created) do
        message("只有 created 状态可以提交")
      end

      change(set_attribute(:status, :submitted))
    end

    update :approve do
      require_atomic?(false)
      accept([])

      validate attribute_equals(:status, :submitted) do
        message("只有 submitted 状态可以审批")
      end

      change(set_attribute(:status, :approved))

      # 定制 change：模拟审批通过后发邮件（写日志）
      change(
        after_action(fn _changeset, record, _context ->
          Logger.info("[V2] 订单审批通过，发送邮件通知（模拟） order_id=#{record.id}")
          {:ok, record}
        end)
      )
    end

    update :reject do
      accept([])

      validate attribute_in(:status, [:submitted, :approved]) do
        message("只有 submitted/approved 状态可以驳回")
      end

      change(set_attribute(:status, :rejected))
    end

    update :emergency_approve do
      require_atomic?(false)
      accept([])

      # 定制 action：跳过常规 submitted 校验
      change(set_attribute(:status, :approved))

      change(
        after_action(fn _changeset, record, _context ->
          Logger.info("[V2] 订单加急审批通过（跳过常规流程） order_id=#{record.id}")
          {:ok, record}
        end)
      )
    end
  end

  calculations do
    # 定制 calculation：利润率 = (售价 - 成本) / 成本
    calculate :margin_rate, :decimal, {__MODULE__.MarginRate, []} do
      public?(true)
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if(expr(^actor(:role) in [:buyer, :admin]))
    end

    policy action_type(:read) do
      authorize_if(always())
    end

    policy action_type(:update) do
      authorize_if(expr(^actor(:role) == :admin or created_by_id == ^actor(:id)))
    end
  end

  defmodule MarginRate do
    @moduledoc false
    use Ash.Resource.Calculation

    @impl true
    def calculate(records, _opts, _context) do
      Enum.map(records, fn record ->
        cost = record.cost_amount || Decimal.new(0)
        sell = record.sell_amount || Decimal.new(0)

        if Decimal.eq?(cost, Decimal.new(0)) do
          Decimal.new(0)
        else
          sell
          |> Decimal.sub(cost)
          |> Decimal.div(cost)
        end
      end)
    end
  end
end
