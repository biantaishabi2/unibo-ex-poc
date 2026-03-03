# Workflow: rating_lifecycle — 评分记录生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reset
#   update --> update
#   update --> reset
#   reset --> update
# ```
defmodule UniboV4.Helpdesk.Rating do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_ratings"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_rating

    queries do
      get :get_helpdesk_rating, :read
      list :list_helpdesk_ratings, :read
    end

    mutations do
      create :create_helpdesk_rating, :create
      update :update_helpdesk_rating, :update
      update :reset_helpdesk_rating, :reset
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :res_model, :string do
      allow_nil? false
      public? true
    end
    attribute :res_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :res_name, :string, public?: true
    attribute :parent_res_model, :string, public?: true
    attribute :parent_res_id, :uuid, public?: true
    attribute :rating, :decimal do
      default 0
      public? true
    end
    attribute :rating_text, :atom do
      constraints one_of: [:top, :ok, :ko, :none]
      default :none
      public? true
    end
    attribute :feedback, :string, public?: true
    attribute :consumed, :boolean do
      default false
      public? true
    end
    attribute :access_token, :string, public?: true
    attribute :helpdesk_ticket_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :ticket, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      source_attribute :helpdesk_ticket_id
    end
    belongs_to :rated_partner, UniboV4.Helpdesk.Partner do
      public? true
    end
    belongs_to :partner, UniboV4.Helpdesk.Partner do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:res_model, :res_id, :parent_res_model, :parent_res_id, :rating, :feedback, :helpdesk_ticket_id]
      argument :rated_partner_id, :uuid
      argument :partner_id, :uuid
      validate present(:res_model)
      validate present(:res_id)
      # TODO: 不支持的 change effect compute
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
      accept [:rating, :feedback, :consumed]
      # TODO: 不支持的 change effect compute
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
    update :reset do
      accept []
      change set_attribute(:rating, 0)
      change set_attribute(:consumed, false)
      # TODO: 不支持的 change effect compute
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
    validate compare(:rating, greater_than_or_equal_to: 0)
    validate compare(:rating, less_than_or_equal_to: 5)
  end

end
