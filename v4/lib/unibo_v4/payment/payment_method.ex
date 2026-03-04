# Workflow: payment_method_lifecycle — 支付方式生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> set_default
#   create --> expire
#   create --> destroy
#   update --> set_default
#   update --> expire
#   update --> destroy
#   set_default --> update
#   set_default --> expire
#   set_default --> destroy
#   expire --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Payment.PaymentMethod do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "payment_methods"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :gl_account_id, :string, public?: true
    attribute :fin_account_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :is_default, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :party, UniboV4.Payment.Party do
      public? true
    end
    has_many :payments, UniboV4.Payment.Payment do
      public? true
      destination_attribute :payment_method_id
    end
    has_many :gateway_responses, UniboV4.Payment.PaymentGatewayResponse do
      public? true
      destination_attribute :payment_method_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_method_type_id, :description, :gl_account_id, :fin_account_id, :from_date, :thru_date, :is_default]
      validate present(:party_id)
      validate present(:payment_method_type_id)
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
      accept [:description, :gl_account_id, :fin_account_id, :from_date, :thru_date, :is_default]
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
    update :set_default do
      accept [:is_default]
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
    update :expire do
      accept [:thru_date]
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
