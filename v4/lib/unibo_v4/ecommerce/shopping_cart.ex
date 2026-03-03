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
defmodule UniboV4.Ecommerce.ShoppingCart do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Ecommerce.ShoppingCart.Notifier]

  postgres do
    table "ecommerce_shopping_carts"
    repo UniboV4.Repo
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
    attribute :access_token, :string, public?: true
    attribute :cart_recovery_email_sent, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :total_amount
    calculate :item_count, :integer, expr(sum(visible_lines, field: :product_uom_qty, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :is_abandoned
    # TODO: 不支持的 calculation 表达式 :only_services
  end

  relationships do
    belongs_to :owner, UniboV4.Ecommerce.User do
      public? true
    end
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
    belongs_to :pricelist, UniboV4.Ecommerce.Pricelist do
      public? true
    end
    belongs_to :carrier, UniboV4.Ecommerce.DeliveryCarrier do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      accept []
      argument :product_id, :uuid, allow_nil?: false
      argument :quantity, :integer, allow_nil?: false
      argument :attributes_json, :string
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect remove_delivery_lines
      # TODO: 不支持的 change effect update_session_quantity
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
      accept []
      argument :pricelist_id, :uuid, allow_nil?: false
      # TODO: 不支持的 change effect recompute_all_line_prices
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

end
