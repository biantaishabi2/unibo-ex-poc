# Workflow: membership_flow — 会员状态流转
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> cancel
#   cancel --> renew
#   renew --> cancel
# ```
defmodule UniboV4.Membership.MembershipLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Membership,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Membership.MembershipLine.Notifier]

  postgres do
    table "membership_lines"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :date_from, :date, public?: true
    attribute :date_to, :date, public?: true
    attribute :date_cancel, :date, public?: true
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
    end
    attribute :member_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:none, :waiting, :invoiced, :paid, :free, :canceled, :old]
      default :none
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_active
  end

  relationships do
    belongs_to :partner, UniboV4.Membership.ResPartner do
      public? true
      allow_nil? false
    end
    belongs_to :membership, UniboV4.Membership.MembershipProduct do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date_from, :date_to, :date, :member_price, :state]
      argument :partner_id, :uuid, allow_nil?: false
      argument :membership_id, :uuid, allow_nil?: false
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      change manage_relationship(:membership_id, :membership, type: :append, on_lookup: :relate)
      validate present(:member_price)
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
      accept [:date_from, :date_to, :date_cancel, :member_price, :state]
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
    update :cancel do
      accept []
      change set_attribute(:state, :canceled)
      change set_attribute(:date_cancel, &Date.utc_today/0)
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
    update :renew do
      accept [:date_to, :member_price]
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
    validate compare(:member_price, greater_than_or_equal_to: 0)
  end

end
