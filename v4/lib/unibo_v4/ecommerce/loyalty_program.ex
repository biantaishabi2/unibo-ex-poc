# Workflow: loyalty_program_lifecycle — 忠诚度计划管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.LoyaltyProgram do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_loyalty_programs"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_loyalty_program

    queries do
      get :get_ecommerce_loyalty_program, :read
      list :list_ecommerce_loyalty_programs, :read
    end

    mutations do
      create :create_ecommerce_loyalty_program, :create
      update :update_ecommerce_loyalty_program, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :program_type, :atom do
      constraints one_of: [:coupon, :loyalty, :promotion, :gift_card, :ewallet]
      default :loyalty
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :sale_ok, :boolean do
      default true
      public? true
    end
    attribute :ecommerce_ok, :boolean do
      default true
      public? true
    end
    attribute :trigger, :atom do
      constraints one_of: [:auto, :with_code]
      default :auto
      public? true
    end
    attribute :applies_on, :atom do
      constraints one_of: [:current, :future, :both]
      default :current
      public? true
    end
    attribute :date_from, :date, public?: true
    attribute :date_to, :date, public?: true
    attribute :limit_usage, :boolean do
      default false
      public? true
    end
    attribute :max_usage, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :rules, UniboV4.Ecommerce.LoyaltyRule do
      public? true
      destination_attribute :program_id
    end
    has_many :rewards, UniboV4.Ecommerce.LoyaltyReward do
      public? true
      destination_attribute :program_id
    end
    has_many :cards, UniboV4.Ecommerce.LoyaltyCard do
      public? true
      destination_attribute :program_id
    end
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :program_type, :active, :sale_ok, :ecommerce_ok, :trigger, :applies_on, :date_from, :date_to, :limit_usage, :max_usage]
      argument :website_id, :uuid
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:name, :program_type, :active, :sale_ok, :ecommerce_ok, :trigger, :applies_on, :date_from, :date_to, :limit_usage, :max_usage]
      argument :website_id, :uuid
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    identity :unique_loyalty_program_name, [:name]
  end

end
