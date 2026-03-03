# Workflow: activity_lifecycle — 活动生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> complete
#   create --> cancel
#   update --> update
#   update --> complete
#   update --> cancel
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.CRM.Activity do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_activities"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_activity

    queries do
      get :get_crm_activity, :read
      list :list_crm_activitys, :read
    end

    mutations do
      create :create_crm_activity, :create
      update :update_crm_activity, :update
      update :complete_crm_activity, :complete
      update :cancel_crm_activity, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :activity_type, :atom do
      allow_nil? false
      constraints one_of: [:phone_call, :email, :meeting, :note, :other]
      public? true
    end
    attribute :subject, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :activity_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_deadline, :utc_datetime, public?: true
    attribute :duration_minutes, :integer, public?: true
    attribute :status, :atom do
      constraints one_of: [:planned, :completed, :cancelled]
      default :planned
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact do
      public? true
    end
    belongs_to :lead, UniboV4.CRM.Lead do
      public? true
    end
    belongs_to :created_by, UniboV4.CRM.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:activity_type, :subject, :description, :activity_date, :date_deadline, :duration_minutes]
      argument :contact_id, :uuid
      argument :lead_id, :uuid
      validate present(:subject)
      change relate_actor(:created_by)
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
      accept [:subject, :description, :activity_date, :date_deadline, :duration_minutes, :status]
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
    update :complete do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :planned do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :planned}))
        end
      end
      # message: "只有计划中的活动可以完成"
      change set_attribute(:status, :completed)
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
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :planned do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :planned}))
        end
      end
      # message: "只有计划中的活动可以取消"
      change set_attribute(:status, :cancelled)
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
