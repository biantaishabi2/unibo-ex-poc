# Workflow: visitor_lifecycle — 访客生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> upsert
#   upsert --> track_visit
#   track_visit --> track_visit
#   track_visit --> merge
#   track_visit --> cleanup
#   merge --> [*]
#   cleanup --> [*]
# ```
defmodule UniboV4.Blog.Visitor do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "blog_visitors"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :access_token, :string do
      allow_nil? false
      public? true
    end
    attribute :visit_count, :integer do
      default 0
      public? true
    end
    attribute :last_connection_datetime, :utc_datetime, public?: true
    attribute :country_id, :uuid, public?: true
    attribute :lang_id, :uuid, public?: true
    attribute :timezone, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_connected
    calculate :visitor_page_count, :integer, expr(count(website_tracks, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :time_since_last_action
  end

  relationships do
    belongs_to :partner, UniboV4.Blog.User do
      public? true
    end
    has_many :website_tracks, UniboV4.Blog.WebsiteTrack do
      public? true
    end
    belongs_to :last_visited_page, UniboV4.Blog.WebPage do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :upsert do
      accept [:access_token, :country_id, :lang_id, :timezone]
      validate present(:access_token)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :track_visit do
      accept []
      change fn changeset, _context ->
        visit_count = Ash.Changeset.get_attribute(changeset, :visit_count)

        if visit_count do
          Ash.Changeset.force_change_attribute(changeset, :visit_count, Decimal.add(visit_count, 1))
        else
          changeset
        end
      end
      # TODO: 跨实体聚合表达式暂不支持
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
    update :merge do
      argument :target_visitor_id, :uuid, allow_nil?: false
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
    destroy :cleanup do
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_access_token, [:access_token]
  end

end
