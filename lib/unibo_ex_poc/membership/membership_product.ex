# Workflow: membership_product_maintain_flow — 会员产品维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Membership.MembershipProduct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "会员产品，定义会员类型和有效期"
  end

  postgres do
    table "membership_products"
    repo UniboV4.Repo
  end

  graphql do
    type :membership_membership_product

    queries do
      get :get_membership_membership_product, :read
      list :list_membership_membership_products, :read
    end

    mutations do
      create :create_membership_membership_product, :create
      update :update_membership_membership_product, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "会员产品名称"
    end
    attribute :membership_date_from, :date do
      public? true
      description "会员有效期起始"
    end
    attribute :membership_date_to, :date do
      public? true
      description "会员有效期截止"
    end
    attribute :list_price, :decimal do
      public? true
      description "标准会费"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :membership_lines, UniboV4.Membership.MembershipLine do
      public? true
      destination_attribute :membership_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :membership_date_from, :membership_date_to, :list_price]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :membership_date_from, :membership_date_to, :list_price]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
