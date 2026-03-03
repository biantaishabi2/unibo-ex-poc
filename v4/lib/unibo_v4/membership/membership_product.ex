# Workflow: membership_product_maintain_flow — 会员产品维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Membership.MembershipProduct do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :membership_date_from, :date, public?: true
    attribute :membership_date_to, :date, public?: true
    attribute :list_price, :decimal, public?: true
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
      accept [:name, :membership_date_from, :membership_date_to, :list_price]
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
