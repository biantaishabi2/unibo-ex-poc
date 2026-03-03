# Workflow: warranty_maintain_flow — 保修记录维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Repair.Warranty do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "repair_warranties"
    repo UniboV4.Repo
  end

  graphql do
    type :repair_warranty

    queries do
      get :get_repair_warranty, :read
      list :list_repair_warrantys, :read
    end

    mutations do
      create :create_repair_warranty, :create
      update :update_repair_warranty, :update
      destroy :delete_repair_warranty, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :warranty_number, :string do
      allow_nil? false
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
    end
    attribute :warranty_type, :atom do
      allow_nil? false
      constraints one_of: [:manufacturer, :extended, :on_site, :carry_in]
      public? true
    end
    attribute :terms, :string, public?: true
    attribute :is_active, :boolean, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:warranty_number, :start_date, :end_date, :warranty_type, :terms]
      argument :customer_id, :uuid, allow_nil?: false
      argument :product_id, :uuid, allow_nil?: false
      argument :sales_order_id, :uuid
      validate present(:warranty_number)
      # TODO: 不支持的 action 内校验规则 date_after
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
      accept [:end_date, :terms]
      # skipped: validate date_after :end_date (incompatible with bulk update atomic path)
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
    # TODO: 不支持的校验规则 unique
  end

  identities do
    identity :unique_warranty_number, [:warranty_number]
  end

end
