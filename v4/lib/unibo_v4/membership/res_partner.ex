# Workflow: partner_membership_invoice_flow — 合作伙伴会员发票创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create_membership_invoice
#   create_membership_invoice --> [*]
# ```
defmodule UniboV4.Membership.ResPartner do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "membership_res_partners"
    repo UniboV4.Repo
  end

  graphql do
    type :membership_res_partner

    queries do
      get :get_membership_res_partner, :read
      list :list_membership_res_partners, :read
    end

    mutations do
      update :create_membership_invoice_membership_res_partner, :create_membership_invoice
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :free_member, :boolean do
      default false
      public? true
    end
    attribute :membership_amount, :decimal, public?: true
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :membership_state
    # TODO: 不支持的 calculation 表达式 :membership_start
    # TODO: 不支持的 calculation 表达式 :membership_stop
    # TODO: 不支持的 calculation 表达式 :membership_cancel
  end

  relationships do
    has_many :member_lines, UniboV4.Membership.MembershipLine do
      public? true
      destination_attribute :partner_id
    end
    belongs_to :associate_member, UniboV4.Membership.ResPartner do
      public? true
    end
  end

  actions do
    defaults [:read]
    update :create_membership_invoice do
      primary? true
      accept []
      argument :membership_id, :uuid, allow_nil?: false
      argument :amount, :decimal, allow_nil?: false
      # skipped: validate present :membership_id (incompatible with bulk update atomic path)
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
