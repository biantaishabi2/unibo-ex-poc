# Workflow: program_lifecycle_flow — 积分计划生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   update --> update
#   update --> activate
#   activate --> pause
#   activate --> expire
#   pause --> activate
#   pause --> expire
#   expire --> [*] : expired
# ```
defmodule UniboV4.Loyalty.Loyalty.LoyaltyProgram do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Loyalty.Loyalty.LoyaltyProgram.Notifier]

  postgres do
    table "loyalty_programs"
    repo UniboV4.Repo
  end

  graphql do
    type :loyalty_loyalty_program

    queries do
      get :get_loyalty_loyalty_program, :read
      list :list_loyalty_loyalty_programs, :read
    end

    mutations do
      create :create_loyalty_loyalty_program, :create
      update :update_loyalty_loyalty_program, :update
      update :activate_loyalty_loyalty_program, :activate
      update :pause_loyalty_loyalty_program, :pause
      update :expire_loyalty_loyalty_program, :expire
      destroy :delete_loyalty_loyalty_program, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :program_type, :atom do
      allow_nil? false
      constraints one_of: [:points, :cashback, :discount, :mixed]
      default :points
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :paused, :expired]
      default :draft
      public? true
    end
    attribute :points_currency_name, :string do
      default "积分"
      public? true
    end
    attribute :points_per_currency, :decimal do
      default 1.0
      public? true
    end
    attribute :require_code, :boolean do
      default false
      public? true
    end
    attribute :use_limit_per_order, :integer, public?: true
    attribute :use_limit_per_customer, :integer, public?: true
    attribute :use_limit_per_program, :integer, public?: true
    attribute :from_date, :date, public?: true
    attribute :thru_date, :date, public?: true
    attribute :portal_visible, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :rules, UniboV4.Loyalty.Loyalty.LoyaltyRule do
      public? true
      destination_attribute :program_id
    end
    has_many :rewards, UniboV4.Loyalty.Loyalty.LoyaltyReward do
      public? true
      destination_attribute :program_id
    end
    has_many :coupons, UniboV4.Loyalty.Loyalty.Coupon do
      public? true
      destination_attribute :program_id
    end
    has_many :cards, UniboV4.Loyalty.Loyalty.LoyaltyCard do
      public? true
      destination_attribute :program_id
    end
    has_many :translations, UniboV4.Loyalty.Loyalty.LoyaltyProgramTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :program_type, :points_currency_name, :points_per_currency, :require_code, :use_limit_per_order, :use_limit_per_customer, :use_limit_per_program, :from_date, :thru_date, :portal_visible]
      validate present(:name)
      validate present(:program_type)
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
      accept [:name, :description, :program_type, :points_per_currency, :use_limit_per_order, :use_limit_per_customer, :thru_date, :portal_visible]
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
      accept [:from_date]
      change set_attribute(:status, :active)
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
    update :pause do
      accept []
      change set_attribute(:status, :paused)
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

  validations do
    validate compare(:points_per_currency, greater_than: 0)
  end

end
