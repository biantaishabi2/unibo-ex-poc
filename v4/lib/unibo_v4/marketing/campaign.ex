# Workflow: campaign_lifecycle — 营销活动生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> launch
#   update --> launch
#   launch --> pause
#   launch --> complete
#   launch --> cancel
#   pause --> resume
#   pause --> cancel
#   resume --> pause
#   resume --> complete
#   resume --> cancel
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.Marketing.Campaign do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Marketing.Campaign.Notifier]

  postgres do
    table "marketing_campaigns"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :campaign_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :running, :paused, :completed, :cancelled]
      default :draft
      public? true
    end
    attribute :campaign_type, :atom do
      constraints one_of: [:email, :social, :event, :promotion, :other]
      default :email
      public? true
    end
    attribute :start_date, :date, public?: true
    attribute :end_date, :date, public?: true
    attribute :budget, :decimal, public?: true
    attribute :actual_cost, :decimal, public?: true
    attribute :description, :string, public?: true
    attribute :utm_campaign_id, :uuid, public?: true
    attribute :utm_medium_id, :uuid, public?: true
    attribute :utm_source_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :roles, UniboV4.Marketing.CampaignRole do
      public? true
    end
    has_many :mailings, UniboV4.Marketing.Mailing do
      public? true
    end
    has_many :events, UniboV4.Marketing.Event do
      public? true
    end
    has_many :social_posts, UniboV4.Marketing.SocialPost do
      public? true
    end
    belongs_to :created_by, UniboV4.Marketing.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:campaign_code, :name, :campaign_type, :start_date, :end_date, :budget, :description, :utm_campaign_id, :utm_medium_id, :utm_source_id]
      validate present(:campaign_code)
      validate present(:name)
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
      accept [:name, :status, :start_date, :end_date, :budget, :actual_cost, :description, :utm_campaign_id, :utm_medium_id, :utm_source_id]
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
    update :launch do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以启动"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :running)
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以暂停"
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
    update :resume do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :paused do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :paused}))
        end
      end
      # message: "只有暂停状态可以恢复"
      change set_attribute(:status, :running)
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
      accept [:actual_cost]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:running, :paused] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:running, :paused]}))
        end
      end
      # message: "只有运行中或暂停状态可以完成"
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
        if current in [:draft, :running, :paused] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :running, :paused]}))
        end
      end
      # message: "已完成的活动不可取消"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancelled)
      # TODO: 不支持的 change effect cascade
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
    identity :unique_campaign_code, [:campaign_code]
  end

end
