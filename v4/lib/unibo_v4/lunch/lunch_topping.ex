# Workflow: topping_management — 配料管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Lunch.LunchTopping do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lunch_toppings"
    repo UniboV4.Repo
  end

  graphql do
    type :lunch_lunch_topping

    queries do
      get :get_lunch_lunch_topping, :read
      list :list_lunch_lunch_toppings, :read
    end

    mutations do
      create :create_lunch_lunch_topping, :create
      update :update_lunch_lunch_topping, :update
      destroy :delete_lunch_lunch_topping, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :topping_category, :integer do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :display_name
  end

  relationships do
    belongs_to :supplier, UniboV4.Lunch.LunchSupplier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :price, :topping_category]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
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
      accept [:name, :price, :topping_category]
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

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
    validate one_of(:topping_category, [])
  end

end
