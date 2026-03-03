# Workflow: gateway_response_record_flow — 网关响应记录流程（仅创建和查询，审计记录不可变）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Payment.Payment.PaymentGatewayResponse do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "payment_gateway_responses"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_payment_gateway_response

    queries do
      get :get_payment_payment_gateway_response, :read
      list :list_payment_payment_gateway_responses, :read
    end

    mutations do
      create :create_payment_payment_gateway_response, :create
      update :update_payment_payment_gateway_response, :update
      destroy :delete_payment_payment_gateway_response, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_service_type_enum_id, :atom do
      allow_nil? false
      constraints one_of: [:auth, :capture, :release, :refund, :void]
      public? true
    end
    attribute :order_payment_preference_id, :string, public?: true
    attribute :payment_method_type_id, :string, public?: true
    attribute :trans_code_enum_id, :string, public?: true
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency_uom_id, :string do
      allow_nil? false
      public? true
    end
    attribute :reference_num, :string, public?: true
    attribute :alt_reference, :string, public?: true
    attribute :sub_reference, :string, public?: true
    attribute :gateway_code, :string, public?: true
    attribute :gateway_flag, :string, public?: true
    attribute :gateway_avs_result, :string, public?: true
    attribute :gateway_cv_result, :string, public?: true
    attribute :gateway_score_result, :string, public?: true
    attribute :gateway_message, :string, public?: true
    attribute :transaction_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :result_declined, :boolean do
      default false
      public? true
    end
    attribute :result_nsf, :boolean do
      default false
      public? true
    end
    attribute :result_bad_expire, :boolean do
      default false
      public? true
    end
    attribute :result_bad_card_number, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :payment_method, UniboV4.Payment.Payment.PaymentMethod do
      public? true
    end
    belongs_to :provider, UniboV4.Payment.Payment.PaymentProvider do
      public? true
      source_attribute :payment_provider_id
    end
    has_many :payments, UniboV4.Payment.Payment.Payment do
      public? true
      destination_attribute :payment_gateway_response_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_service_type_enum_id, :order_payment_preference_id, :payment_method_type_id, :trans_code_enum_id, :amount, :currency_uom_id, :reference_num, :alt_reference, :sub_reference, :gateway_code, :gateway_flag, :gateway_avs_result, :gateway_cv_result, :gateway_score_result, :gateway_message, :transaction_date, :result_declined, :result_nsf, :result_bad_expire, :result_bad_card_number]
      validate present(:payment_service_type_enum_id)
      validate present(:amount)
      validate present(:currency_uom_id)
      validate present(:transaction_date)
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
      accept [:gateway_message, :gateway_code, :gateway_flag]
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
