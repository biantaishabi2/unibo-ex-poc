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
defmodule UniboExPoc.Lunch.LunchTopping do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "午餐配料，属于供应商的3-slot配料分类体系"
  end

  postgres do
    table "lunch_toppings"
    repo UniboExPoc.Repo
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
      description "配料名称"
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
      description "配料价格"
    end
    attribute :topping_category, :integer do
      allow_nil? false
      public? true
      description "所属配料分类插槽（1/2/3对应supplier的3个分类）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :display_name, :string, expr(name <>  ( <> format_currency(price) <> ))
  end

  relationships do
    belongs_to :supplier, UniboExPoc.Lunch.LunchSupplier do
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
    validate one_of(:topping_category, [1, 2, 3])
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
