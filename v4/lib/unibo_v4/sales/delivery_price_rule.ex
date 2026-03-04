# Workflow: price_rule_lifecycle — 运费规则管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Sales.DeliveryPriceRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_delivery_price_rules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :variable, :atom do
      allow_nil? false
      constraints one_of: [:weight, :volume, :wv, :price, :quantity]
      public? true
    end
    attribute :operator, :atom do
      allow_nil? false
      constraints one_of: [:"==", :"<=", :"<", :">=", :">"]
      public? true
    end
    attribute :max_value, :decimal do
      default 0
      public? true
    end
    attribute :list_base_price, :decimal do
      default 0
      public? true
    end
    attribute :list_price, :decimal do
      default 0
      public? true
    end
    attribute :variable_factor, :atom do
      allow_nil? false
      constraints one_of: [:weight, :volume, :wv, :price, :quantity]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :carrier, UniboV4.Sales.DeliveryCarrier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:sequence, :variable, :operator, :max_value, :list_base_price, :list_price, :variable_factor]
      argument :carrier_id, :uuid, allow_nil?: false
      change manage_relationship(:carrier_id, :carrier, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :update do
      primary? true
      accept [:sequence, :variable, :operator, :max_value, :list_base_price, :list_price, :variable_factor]
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
    validate compare(:max_value, greater_than_or_equal_to: 0)
    validate compare(:list_base_price, greater_than_or_equal_to: 0)
    validate compare(:list_price, greater_than_or_equal_to: 0)
  end

end
