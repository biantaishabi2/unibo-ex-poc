# Workflow: shopping_cart_lifecycle — 购物车生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> cart_update
#   create --> update_pricelist
#   create --> select_carrier
#   update --> update
#   update --> cart_update
#   update --> update_pricelist
#   update --> select_carrier
#   update --> convert
#   cart_update --> update
#   cart_update --> cart_update
#   cart_update --> update_pricelist
#   cart_update --> select_carrier
#   cart_update --> convert
#   update_pricelist --> update
#   update_pricelist --> cart_update
#   update_pricelist --> select_carrier
#   update_pricelist --> convert
#   select_carrier --> update
#   select_carrier --> cart_update
#   select_carrier --> update_pricelist
#   select_carrier --> convert
#   convert --> [*] : converted
#   recover --> update
#   recover --> cart_update
#   recover --> update_pricelist
#   recover --> select_carrier
#   recover --> convert
# ```
defmodule UniboExPoc.Ecommerce.ShoppingCart do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Ecommerce.ShoppingCart.Notifier]

  resource do
    description "购物车"
  end

  postgres do
    table "ecommerce_shopping_carts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_shopping_cart

    queries do
      get :get_ecommerce_shopping_cart, :read
      list :list_ecommerce_shopping_carts, :read
    end

    mutations do
      create :create_ecommerce_shopping_cart, :create
      update :update_ecommerce_shopping_cart, :update
      update :convert_ecommerce_shopping_cart, :convert
      update :cart_update_ecommerce_shopping_cart, :cart_update
      update :recover_ecommerce_shopping_cart, :recover
      update :update_pricelist_ecommerce_shopping_cart, :update_pricelist
      update :select_carrier_ecommerce_shopping_cart, :select_carrier
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:active, :converted, :abandoned]
      default :active
      public? true
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :access_token, :string do
      public? true
      description "用于弃购恢复链接"
    end
    attribute :cart_recovery_email_sent, :boolean do
      default false
      public? true
      description "弃购恢复邮件是否已发送"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :total_amount, :decimal, expr(sum(visible_lines, field: :price_total, query: [filter: expr(true)]))
    calculate :item_count, :integer, expr(sum(visible_lines, field: :product_uom_qty, query: [filter: expr(true)]))
    calculate :is_abandoned, :boolean, expr(status == active and age > website.cart_abandoned_delay)
    calculate :only_services, :boolean, expr(all(lines.product.type == 'service'))
  end

  relationships do
    belongs_to :owner, UniboExPoc.Ecommerce.User do
      public? true
    end
    belongs_to :website, UniboExPoc.Ecommerce.WebSite do
      public? true
    end
    belongs_to :pricelist, UniboExPoc.Ecommerce.Pricelist do
      public? true
    end
    belongs_to :carrier, UniboExPoc.Ecommerce.DeliveryCarrier do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:currency]
      change relate_actor(:owner)
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
      accept [:status]
      argument :total_amount, :decimal
      argument :item_count, :string
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
    update :convert do
      description "转为订单"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃购物车可以转为订单"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :converted)
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
    update :cart_update do
      description "核心加购逻辑：(a) 校验订单处于 draft 状态 → (b) 解析产品变体 → (c) 查找已有相同产品行合并数量 → (d) 通过 _get_closest_possible_combination() 解析最近有效组合 → (e) 移除配送行后重新计算
"
      accept []
      argument :product_id, :uuid, allow_nil?: false
      argument :quantity, :integer, allow_nil?: false
      argument :attributes_json, :string
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.Ecommerce.Changes.ShoppingCart.CartUpdateCall5
      change UniboExPoc.Ecommerce.Changes.ShoppingCart.CartUpdateCall7
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
    update :recover do
      description "通过 access_token 恢复弃购购物车，支持 merge（合并）和 squash（覆盖）两种模式"
      accept []
      argument :access_token, :string, allow_nil?: false
      argument :mode, :atom
      change set_attribute(:status, :active)
      change set_attribute(:cart_recovery_email_sent, false)
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
    update :update_pricelist do
      description "切换价格表并重算所有行价格"
      accept []
      argument :pricelist_id, :uuid, allow_nil?: false
      change UniboExPoc.Ecommerce.Changes.ShoppingCart.UpdatePricelistCall6
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
    update :select_carrier do
      description "选择物流方式"
      accept []
      argument :carrier_id, :uuid, allow_nil?: false
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
