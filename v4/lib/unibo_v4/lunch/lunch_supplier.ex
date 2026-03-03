# Workflow: supplier_lifecycle — 供应商生命周期（创建→运营→归档）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> send_orders
#   create --> archive
#   update --> update
#   update --> send_orders
#   update --> archive
#   send_orders --> confirm_orders
#   send_orders --> send_orders
#   confirm_orders --> send_orders
#   confirm_orders --> archive
#   archive --> unarchive
#   unarchive --> update
#   unarchive --> send_orders
#   unarchive --> archive
# ```
defmodule UniboV4.Lunch.LunchSupplier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Lunch.LunchSupplier.Notifier]

  postgres do
    table "lunch_suppliers"
    repo UniboV4.Repo
  end

  graphql do
    type :lunch_lunch_supplier

    queries do
      get :get_lunch_lunch_supplier, :read
      list :list_lunch_lunch_suppliers, :read
    end

    mutations do
      create :create_lunch_lunch_supplier, :create
      update :update_lunch_lunch_supplier, :update
      update :send_orders_lunch_lunch_supplier, :send_orders
      update :confirm_orders_lunch_lunch_supplier, :confirm_orders
      update :archive_lunch_lunch_supplier, :archive
      update :unarchive_lunch_lunch_supplier, :unarchive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :responsible_id, :uuid, public?: true
    attribute :send_by, :atom do
      allow_nil? false
      constraints one_of: [:phone, :email]
      public? true
    end
    attribute :automatic_email_time, :float, public?: true
    attribute :moment, :atom do
      constraints one_of: [:am, :pm]
      public? true
    end
    attribute :tz, :string, public?: true
    attribute :mon, :boolean do
      default false
      public? true
    end
    attribute :tue, :boolean do
      default false
      public? true
    end
    attribute :wed, :boolean do
      default false
      public? true
    end
    attribute :thu, :boolean do
      default false
      public? true
    end
    attribute :fri, :boolean do
      default false
      public? true
    end
    attribute :sat, :boolean do
      default false
      public? true
    end
    attribute :sun, :boolean do
      default false
      public? true
    end
    attribute :recurrency_end_date, :date, public?: true
    attribute :topping_label_1, :string, public?: true
    attribute :topping_quantity_1, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
    end
    attribute :topping_label_2, :string, public?: true
    attribute :topping_quantity_2, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
    end
    attribute :topping_label_3, :string, public?: true
    attribute :topping_quantity_3, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :available_today
    # TODO: 不支持的 calculation 表达式 :order_deadline_passed
    # TODO: 不支持的 calculation 表达式 :show_order_button
    # TODO: 不支持的 calculation 表达式 :show_confirm_button
  end

  relationships do
    belongs_to :partner, UniboV4.Lunch.Partner do
      public? true
      allow_nil? false
    end
    belongs_to :responsible, UniboV4.Lunch.User do
      public? true
    end
    has_many :products, UniboV4.Lunch.LunchProduct do
      public? true
      destination_attribute :supplier_id
    end
    has_many :toppings, UniboV4.Lunch.LunchTopping do
      public? true
      destination_attribute :supplier_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :send_by, :automatic_email_time, :moment, :tz, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :recurrency_end_date, :topping_label_1, :topping_quantity_1, :topping_label_2, :topping_quantity_2, :topping_label_3, :topping_quantity_3]
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:send_by)
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
      accept [:name, :send_by, :automatic_email_time, :moment, :tz, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :recurrency_end_date, :topping_label_1, :topping_quantity_1, :topping_label_2, :topping_quantity_2, :topping_label_3, :topping_quantity_3]
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
    update :send_orders do
      accept []
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
    update :confirm_orders do
      accept []
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
    update :archive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用状态的供应商可以归档"
      change set_attribute(:active, false)
      # TODO: 不支持的 change effect cascade_archive
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
    update :unarchive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有已归档状态的供应商可以取消归档"
      change set_attribute(:active, true)
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
