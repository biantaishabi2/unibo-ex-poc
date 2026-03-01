defmodule UniboV4.CRM.Lead do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.CRM.Lead.Notifier]

  postgres do
    table "crm_leads"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_lead

    queries do
      get :get_crm_lead, :read
      list :list_crm_leads, :read
    end

    mutations do
      create :create_crm_lead, :create
      update :update_crm_lead, :update
      update :convert_opportunity_crm_lead, :convert_opportunity
      update :win_crm_lead, :win
      update :lose_crm_lead, :lose
      update :assign_salesperson_crm_lead, :assign_salesperson
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      constraints one_of: [:lead, :opportunity]
      default :lead
      public? true
    end
    attribute :partner_name, :string, public?: true
    attribute :contact_name, :string, public?: true
    attribute :email_from, :string, public?: true
    attribute :phone, :string, public?: true
    attribute :mobile, :string, public?: true
    attribute :expected_revenue, :decimal, public?: true
    attribute :prorated_revenue, :decimal, public?: true
    attribute :probability, :decimal, public?: true
    attribute :automated_probability, :decimal, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1", :"2", :"3"]
      default :"0"
      public? true
    end
    attribute :tag_ids, :string, public?: true
    attribute :source, :string, public?: true
    attribute :lost_reason, :string, public?: true
    attribute :kanban_state, :atom do
      constraints one_of: [:grey, :red, :green]
      default :grey
      public? true
    end
    attribute :lead_properties, :map, public?: true
    attribute :date_deadline, :date, public?: true
    attribute :date_open, :utc_datetime, public?: true
    attribute :date_closed, :utc_datetime, public?: true
    attribute :date_conversion, :utc_datetime, public?: true
    attribute :date_last_stage_update, :utc_datetime, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :contact, UniboV4.CRM.Contact do
      public? true
    end
    belongs_to :stage, UniboV4.CRM.LeadStage do
      public? true
    end
    belongs_to :assigned_to, UniboV4.CRM.User do
      public? true
    end
    belongs_to :team, UniboV4.CRM.SalesTeam do
      public? true
    end
    has_many :activities, UniboV4.CRM.Activity do
      public? true
    end
    has_many :calendar_events, UniboV4.CRM.CalendarEvent do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :type, :partner_name, :contact_name, :email_from, :phone, :mobile, :expected_revenue, :probability, :priority, :tag_ids, :source, :date_deadline, :notes, :lead_properties]
      argument :contact_id, :uuid
      argument :stage_id, :uuid
      argument :team_id, :uuid
      validate present(:name)
      # TODO: 不支持的 change effect compute
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
      accept [:name, :partner_name, :contact_name, :email_from, :phone, :mobile, :expected_revenue, :probability, :priority, :tag_ids, :source, :date_deadline, :notes, :lead_properties]
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect compute
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
    update :convert_opportunity do
      accept []
      argument :contact_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :type)
        if current == :lead do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :type, message: "must equal %{value}", vars: %{value: :lead}))
        end
      end
      # message: "只有 lead 类型才能转为 opportunity"
      change set_attribute(:type, :opportunity)
      change set_attribute(:date_conversion, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect compute
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
    update :win do
      accept []
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      change set_attribute(:probability, 100)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect compute
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
    update :lose do
      accept [:lost_reason]
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      change set_attribute(:active, false)
      change set_attribute(:probability, 0)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect compute
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
    action :merge do
      argument :source_lead_ids, :string, allow_nil?: false
      # TODO: generic action 不支持 change，需要用 run
    end
    update :assign_salesperson do
      accept []
      argument :user_id, :uuid
      argument :team_id, :uuid
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect compute
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

end
