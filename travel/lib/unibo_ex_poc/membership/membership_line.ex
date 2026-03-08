# Workflow: membership_flow — 会员状态流转
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> cancel
#   cancel --> renew
#   renew --> cancel
# ```
defmodule UniboExPoc.Membership.MembershipLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Membership.MembershipLine.Notifier]

  resource do
    description "会员记录行，跟踪合作伙伴的会员产品、有效期和支付状态"
  end

  postgres do
    table "membership_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :membership_membership_line

    queries do
      get :get_membership_membership_line, :read
      list :list_membership_membership_lines, :read
    end

    mutations do
      create :create_membership_membership_line, :create
      update :update_membership_membership_line, :update
      update :cancel_membership_membership_line, :cancel
      update :renew_membership_membership_line, :renew
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date_from, :date do
      public? true
      description "会员开始日期"
    end
    attribute :date_to, :date do
      public? true
      description "会员结束日期"
    end
    attribute :date_cancel, :date do
      public? true
      description "取消日期"
    end
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
      description "加入日期"
    end
    attribute :member_price, :decimal do
      allow_nil? false
      public? true
      description "会费金额"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:none, :waiting, :invoiced, :paid, :free, :canceled, :old]
      default :none
      public? true
      description "会员状态（none=非会员, waiting=等待中, invoiced=已开票, paid=已付费, free=免费, canceled=已取消, old=过期）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_active, :boolean, {UniboExPoc.Membership.Calculations.MembershipLine.IsActive, []}
  end

  relationships do
    belongs_to :partner, UniboExPoc.Membership.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
    belongs_to :membership, UniboExPoc.Membership.MembershipProduct do
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
      description "取消会员（设置 date_cancel 并更新状态为 canceled）"
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
      description "续费（更新 date_to 并重置状态）"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
