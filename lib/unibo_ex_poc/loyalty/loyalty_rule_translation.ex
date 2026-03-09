defmodule UniboExPoc.Loyalty.LoyaltyRuleTranslation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "loyalty_loyalty_rule_translations"
    repo UniboExPoc.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :locale, :string do
      allow_nil? false
      public? true
    end
    attribute :field_name, :string do
      allow_nil? false
      public? true
    end
    attribute :value, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :loyalty_rule, UniboExPoc.Loyalty.LoyaltyRule do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:loyalty_rule_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
