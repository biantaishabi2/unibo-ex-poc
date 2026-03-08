# Workflow: segment_maintain_flow — 客户分群维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> refresh_count
#   update --> refresh_count
#   refresh_count --> [*]
# ```
defmodule UniboV4.Marketing.Segment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "客户分群"
  end

  postgres do
    table "marketing_segments"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_segment

    queries do
      get :get_marketing_segment, :read
      list :list_marketing_segments, :read
    end

    mutations do
      create :create_marketing_segment, :create
      update :update_marketing_segment, :update
      update :refresh_count_marketing_segment, :refresh_count
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :criteria, :string do
      public? true
      description "分群条件（JSON 格式的动态过滤条件，运行时求值）"
    end
    attribute :member_count, :integer do
      default 0
      public? true
      description "缓存值，需定期或按需重算"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :criteria]
      validate present(:name)
      # validation: valid_json_criteria
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :criteria, :member_count]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :refresh_count do
      description "重算成员计数"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboV4.Marketing.Changes.Segment.RefreshCountCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
