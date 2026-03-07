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
defmodule UniboExPoc.Payment.PaymentToken do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "支付令牌，安全存储用户在支付网关上的令牌化卡信息，用于免密/快捷支付"
  end

  postgres do
    table "payment_tokens"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment_token

    queries do
      get :get_payment_payment_token, :read
      list :list_payment_payment_tokens, :read
    end

    mutations do
      create :create_payment_payment_token, :create
      update :update_payment_payment_token, :update
      update :revoke_payment_payment_token, :revoke
      update :expire_payment_payment_token, :expire
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :token_reference, :string do
      allow_nil? false
      public? true
      description "网关返回的令牌引用（不存储原始卡号）"
    end
    attribute :card_last_four, :string do
      public? true
      description "卡号后四位（用于展示）"
    end
    attribute :card_brand, :string do
      public? true
      description "卡品牌（Visa/Mastercard/UnionPay 等）"
    end
    attribute :expiry_date, :string do
      public? true
      description "令牌/卡片过期日期（MM/YY 格式）"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "是否为默认令牌"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :expired, :revoked]
      default :active
      public? true
      description "令牌状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :party, UniboExPoc.Payment.Party do
      public? true
    end
    belongs_to :provider, UniboExPoc.Payment.PaymentProvider do
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
      description "吊销令牌，状态变为 revoked"
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
      description "标记过期，状态变为 expired"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
