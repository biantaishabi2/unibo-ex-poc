# Workflow: repair_fee_maintain_flow — 费用调整维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Repair.RepairFee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "repair_fees"
    repo UniboV4.Repo
  end

  graphql do
    type :repair_repair_fee

    queries do
      get :get_repair_repair_fee, :read
      list :list_repair_repair_fees, :read
    end

    mutations do
      create :create_repair_repair_fee, :create
      update :update_repair_repair_fee, :update
      destroy :delete_repair_repair_fee, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fee_type, :atom do
      allow_nil? false
      constraints one_of: [:diagnostic, :shipping, :discount, :surcharge, :other]
      public? true
    end
    attribute :description, :string do
      allow_nil? false
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :tax_rate, :decimal do
      default 0
      public? true
    end
    attribute :tax_amount, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :repair_ticket, UniboV4.Repair.RepairTicket do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:fee_type, :description, :amount, :tax_rate]
      argument :repair_ticket_id, :uuid, allow_nil?: false
      change manage_relationship(:repair_ticket_id, :repair_ticket, type: :append, on_lookup: :relate)
      validate present(:description)
      # TODO: 不支持的 action 内校验规则 repair_order_editable
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
      accept [:description, :amount, :tax_rate]
      # skipped: validate repair_order_editable : (incompatible with bulk update atomic path)
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
