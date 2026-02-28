defmodule UniboExPoc.PurchasingV3.Order do
  @moduledoc """
  V3 采购订单：金额分级审批 + 风险供应商拦截。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV3,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer]

  @approval_threshold Decimal.new("100000")

  graphql do
    type(:order_v3)

    queries do
      get(:get_order_v3, :read)
      list(:list_orders_v3, :read)
    end

    mutations do
      create(:create_order_v3, :create)
      update(:submit_order_v3, :submit)
      update(:approve_order_v3, :approve)
      update(:senior_approve_order_v3, :senior_approve)
      update(:reject_order_v3, :reject)
    end
  end

  postgres do
    table("v3_orders")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :order_name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :status, :atom do
      constraints(one_of: [:created, :submitted, :approved, :rejected])
      default(:created)
      allow_nil?(false)
      public?(true)
    end

    attribute :total_amount, :decimal do
      allow_nil?(false)
      default(Decimal.new(0))
      public?(true)
    end

    attribute :created_by_id, :uuid do
      allow_nil?(false)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to :supplier, UniboExPoc.PurchasingV3.Party do
      allow_nil?(false)
      public?(true)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:order_name, :total_amount])
      argument(:supplier_id, :uuid, allow_nil?: false)

      change(manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate))

      # 规则：写入创建人
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

      # 规则：供应商必须可合作且非高风险
      change(
        before_action(fn changeset, _context ->
          supplier_id = Ash.Changeset.get_argument(changeset, :supplier_id)

          case Ash.get(UniboExPoc.PurchasingV3.Party, supplier_id, authorize?: false) do
            {:ok, supplier} ->
              cond do
                supplier.status != :active ->
                  Ash.Changeset.add_error(changeset,
                    field: :supplier_id,
                    message: "供应商状态不是可合作状态，禁止下单"
                  )

                supplier.is_blocked ->
                  Ash.Changeset.add_error(changeset,
                    field: :supplier_id,
                    message: "供应商已被禁用，禁止下单"
                  )

                supplier.risk_level == :high ->
                  Ash.Changeset.add_error(changeset,
                    field: :supplier_id,
                    message: "供应商风险等级过高，禁止下单"
                  )

                true ->
                  changeset
              end

            {:error, _error} ->
              Ash.Changeset.add_error(changeset, field: :supplier_id, message: "供应商不存在")
          end
        end)
      )
    end

    update :submit do
      accept([])

      validate attribute_equals(:status, :created) do
        message("只有已创建订单可以提交")
      end

      change(set_attribute(:status, :submitted))
    end

    update :approve do
      require_atomic?(false)
      accept([])

      validate attribute_equals(:status, :submitted) do
        message("只有已提交订单可以审批")
      end

      # 规则：大额订单不能走普通审批
      change(
        before_action(fn changeset, _context ->
          total_amount = Ash.Changeset.get_data(changeset, :total_amount) || Decimal.new(0)

          if Decimal.compare(total_amount, @approval_threshold) == :lt do
            changeset
          else
            Ash.Changeset.add_error(changeset,
              field: :total_amount,
              message: "订单金额达到分级阈值，需走高级审批"
            )
          end
        end)
      )

      change(set_attribute(:status, :approved))
    end

    update :senior_approve do
      require_atomic?(false)
      accept([])

      validate attribute_equals(:status, :submitted) do
        message("只有已提交订单可以执行高级审批")
      end

      # 规则：高级审批只允许处理大额订单
      change(
        before_action(fn changeset, _context ->
          total_amount = Ash.Changeset.get_data(changeset, :total_amount) || Decimal.new(0)

          if Decimal.compare(total_amount, @approval_threshold) in [:eq, :gt] do
            changeset
          else
            Ash.Changeset.add_error(changeset,
              field: :total_amount,
              message: "小额订单无需高级审批"
            )
          end
        end)
      )

      # 规则：高级审批必须由主管角色执行
      change(
        before_action(fn changeset, context ->
          case Map.get(context, :actor) do
            %{role: :admin} ->
              changeset

            _ ->
              Ash.Changeset.add_error(changeset,
                field: :status,
                message: "仅采购主管可执行高级审批"
              )
          end
        end)
      )

      change(set_attribute(:status, :approved))
    end

    update :reject do
      accept([])

      validate attribute_in(:status, [:submitted, :approved]) do
        message("只有已提交/已审批订单可以驳回")
      end

      change(set_attribute(:status, :rejected))
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
end
