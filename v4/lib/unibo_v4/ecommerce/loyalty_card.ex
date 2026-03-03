# Workflow: card_lifecycle — 积分卡生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> add_points
#   create --> share
#   add_points --> add_points
#   add_points --> update
#   add_points --> share
#   update --> update
#   update --> add_points
#   update --> share
#   share --> add_points
#   share --> update
# ```
defmodule UniboV4.Ecommerce.LoyaltyCard do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_loyalty_cards"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_loyalty_card

    queries do
      get :get_ecommerce_loyalty_card, :read
      list :list_ecommerce_loyalty_cards, :read
    end

    mutations do
      create :create_ecommerce_loyalty_card, :create
      update :update_ecommerce_loyalty_card, :update
      update :add_points_ecommerce_loyalty_card, :add_points
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :points, :decimal do
      default 0
      public? true
    end
    attribute :expiration_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboV4.Ecommerce.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.Ecommerce.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:code, :points, :expiration_date]
      argument :program_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
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
      accept [:points, :expiration_date]
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
    update :add_points do
      accept [:points]
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
    action :share do
      argument :card_id, :uuid, allow_nil?: false
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  validations do
    validate compare(:points, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_loyalty_card_code, [:code]
  end

end
