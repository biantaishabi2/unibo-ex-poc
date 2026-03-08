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
defmodule UniboExPoc.Marketing.Campaign do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Marketing.Campaign.Notifier]

  resource do
    description "营销活动"
  end

  postgres do
    table "marketing_campaigns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_campaign

    queries do
      get :get_marketing_campaign, :read
      list :list_marketing_campaigns, :read
    end

    mutations do
      create :create_marketing_campaign, :create
      update :update_marketing_campaign, :update
      update :launch_marketing_campaign, :launch
      update :pause_marketing_campaign, :pause
      update :resume_marketing_campaign, :resume
      update :complete_marketing_campaign, :complete
      update :cancel_marketing_campaign, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :campaign_code, :string do
      allow_nil? false
      public? true
      description "活动编号"
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
    attribute :budget, :decimal do
      public? true
      description "活动预算"
    end
    attribute :actual_cost, :decimal do
      public? true
      description "实际花费"
    end
    attribute :description, :string, public?: true
    attribute :utm_campaign_id, :uuid do
      public? true
      description "UTM 追踪活动关联"
    end
    attribute :utm_medium_id, :uuid do
      public? true
      description "UTM 渠道来源"
    end
    attribute :utm_source_id, :uuid do
      public? true
      description "UTM 流量来源"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :roles, UniboExPoc.Marketing.CampaignRole do
      public? true
    end
    has_many :mailings, UniboExPoc.Marketing.Mailing do
      public? true
    end
    has_many :events, UniboExPoc.Marketing.Event do
      public? true
    end
    has_many :social_posts, UniboExPoc.Marketing.SocialPost do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :created_by_party_id
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
      description "启动活动"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
      description "暂停活动"
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
      description "恢复活动"
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
      description "完成活动"
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
      description "取消活动"
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
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :cancelled)
      # cascade_destroy — 缺少 field，跳过
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
