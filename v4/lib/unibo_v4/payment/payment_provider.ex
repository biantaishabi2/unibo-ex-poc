# Workflow: payment_provider_lifecycle — 支付渠道配置生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> toggle_test_mode
#   create --> destroy
#   update --> activate
#   update --> toggle_test_mode
#   update --> destroy
#   activate --> update
#   activate --> toggle_test_mode
#   activate --> destroy
#   toggle_test_mode --> update
#   toggle_test_mode --> activate
#   toggle_test_mode --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Payment.Payment.PaymentProvider do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "payment_providers"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_payment_provider

    queries do
      get :get_payment_payment_provider, :read
      list :list_payment_payment_providers, :read
    end

    mutations do
      create :create_payment_payment_provider, :create
      update :update_payment_payment_provider, :update
      update :activate_payment_payment_provider, :activate
      update :toggle_test_mode_payment_payment_provider, :toggle_test_mode
      destroy :delete_payment_payment_provider, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :provider_type, :string do
      allow_nil? false
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :test_mode, :boolean do
      default false
      public? true
    end
    attribute :api_endpoint, :string, public?: true
    attribute :api_key, :string, public?: true
    attribute :api_secret, :string, public?: true
    attribute :merchant_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :config_type_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :gateway_responses, UniboV4.Payment.Payment.PaymentGatewayResponse do
      public? true
      destination_attribute :payment_provider_id
    end
    has_many :tokens, UniboV4.Payment.Payment.PaymentToken do
      public? true
      destination_attribute :provider_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :provider_type, :is_active, :test_mode, :api_endpoint, :api_key, :api_secret, :merchant_id, :description, :config_type_id]
      validate present(:name)
      validate present(:provider_type)
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
      accept [:name, :is_active, :test_mode, :api_endpoint, :api_key, :api_secret, :merchant_id, :description]
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
    update :activate do
      accept [:is_active]
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
    update :toggle_test_mode do
      accept [:test_mode]
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
