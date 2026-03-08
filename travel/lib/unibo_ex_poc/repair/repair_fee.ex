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
defmodule UniboExPoc.Repair.RepairFee do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "维修费用调整，记录诊断费、运费、折扣等额外费用，对应 OFBiz ReturnAdjustment 扩展"
  end

  postgres do
    table "repair_fees"
    repo UniboExPoc.Repo
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
      description "费用类型（诊断费/运费/折扣/附加费/其他）"
    end
    attribute :description, :string do
      allow_nil? false
      public? true
      description "费用说明"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "金额（折扣为负数）"
    end
    attribute :tax_rate, :decimal do
      default 0
      public? true
      description "适用税率（%）"
    end
    attribute :tax_amount, :decimal do
      public? true
      description "税额"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :repair_ticket, UniboExPoc.Repair.RepairTicket do
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
      validate attribute_in(:state, [:draft, :confirmed, :under_repair, :repaired])
      # message: "工单为 draft/confirmed/under_repair/repaired 时才可编辑费用"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :amount, :tax_rate]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :confirmed, :under_repair, :repaired] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :confirmed, :under_repair, :repaired]}))
        end
      end
      # message: "工单为 draft/confirmed/under_repair/repaired 时才可编辑费用"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
