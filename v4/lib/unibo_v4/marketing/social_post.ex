# Workflow: social_post_lifecycle — 社交帖子生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish_now
#   create --> schedule
#   update --> publish_now
#   update --> schedule
#   publish_now --> sync_stats
#   schedule --> sync_stats
#   sync_stats --> [*]
# ```
defmodule UniboV4.Marketing.SocialPost do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Marketing.SocialPost.Notifier]

  postgres do
    table "marketing_social_posts"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_social_post

    queries do
      get :get_marketing_social_post, :read
      list :list_marketing_social_posts, :read
    end

    mutations do
      create :create_marketing_social_post, :create
      update :update_marketing_social_post, :update
      update :publish_now_marketing_social_post, :publish_now
      update :schedule_marketing_social_post, :schedule
      update :sync_stats_marketing_social_post, :sync_stats
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :scheduled, :posting, :posted]
      default :draft
      public? true
    end
    attribute :scheduled_date, :utc_datetime, public?: true
    attribute :published_date, :utc_datetime, public?: true
    attribute :media_ids, {:array, :string}, public?: true
    attribute :platform_specific, :string, public?: true
    attribute :utm_source, :string, public?: true
    attribute :utm_medium, :string do
      default "social"
      public? true
    end
    attribute :utm_campaign, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      public? true
    end
    many_to_many :accounts, UniboV4.Marketing.SocialAccount do
      public? true
      through UniboV4.Marketing.SocialPostAccountLink
    end
    belongs_to :created_by, UniboV4.Marketing.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:content, :media_ids, :platform_specific, :utm_source, :utm_medium, :utm_campaign]
      argument :campaign_id, :uuid
      argument :account_ids, {:array, :string}
      validate present(:content)
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
      accept [:content, :media_ids, :platform_specific, :scheduled_date]
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
    update :publish_now do
      accept []
      # skipped: validate present :content (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布或排期"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :posting)
      # TODO: 不支持的 change effect custom
      change set_attribute(:status, :posted)
      change set_attribute(:published_date, &DateTime.utc_now/0)
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
    update :schedule do
      accept [:scheduled_date]
      # skipped: validate present :content (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布或排期"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :scheduled)
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
    update :sync_stats do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :posted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :posted}))
        end
      end
      # message: "只有已发布状态可以同步统计"
      # TODO: 不支持的 change effect custom
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
