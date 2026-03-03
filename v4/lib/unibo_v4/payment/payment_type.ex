# Workflow: payment_type_lifecycle — 支付类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Payment.Payment.PaymentType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "payment_types"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_payment_type

    queries do
      get :get_payment_payment_type, :read
      list :list_payment_payment_types, :read
    end

    mutations do
      create :create_payment_payment_type, :create
      update :update_payment_payment_type, :update
      destroy :delete_payment_payment_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_type_id, :string do
      allow_nil? false
      public? true
    end
    attribute :has_table, :boolean do
      default false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent, UniboV4.Payment.Payment.PaymentType do
      public? true
      source_attribute :parent_type_id
    end
    has_many :children, UniboV4.Payment.Payment.PaymentType do
      public? true
      destination_attribute :parent_type_id
    end
    has_many :payments, UniboV4.Payment.Payment.Payment do
      public? true
      destination_attribute :payment_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_type_id, :has_table, :description]
      validate present(:payment_type_id)
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
      accept [:description, :has_table]
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

  identities do
    identity :unique_payment_type_id, [:payment_type_id]
  end

end
