# Workflow: token_lifecycle — 支付令牌生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> revoke
#   create --> expire
#   update --> revoke
#   update --> expire
#   revoke --> [*]
#   expire --> [*]
# ```
defmodule UniboV4.Payment.PaymentToken do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "payment_tokens"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :token_reference, :string do
      allow_nil? false
      public? true
    end
    attribute :card_last_four, :string, public?: true
    attribute :card_brand, :string, public?: true
    attribute :expiry_date, :string, public?: true
    attribute :is_default, :boolean do
      default false
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :expired, :revoked]
      default :active
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :party, UniboV4.Payment.Party do
      public? true
    end
    belongs_to :provider, UniboV4.Payment.PaymentProvider do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:token_reference, :card_last_four, :card_brand, :expiry_date, :is_default]
      validate present(:party_id)
      validate present(:provider_id)
      validate present(:token_reference)
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
      accept [:is_default, :expiry_date]
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
    update :revoke do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的令牌可以吊销"
      change set_attribute(:status, :revoked)
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
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的令牌可以标记过期"
      change set_attribute(:status, :expired)
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
