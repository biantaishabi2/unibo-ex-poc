# Workflow: quality_tag_maintain_flow — 质量标签维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Quality.QualityTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "质量分类标签，用于检查和警报的分类管理"
  end

  postgres do
    table "quality_tags"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_tag

    queries do
      get :get_quality_quality_tag, :read
      list :list_quality_quality_tags, :read
    end

    mutations do
      create :create_quality_quality_tag, :create
      update :update_quality_quality_tag, :update
      destroy :delete_quality_quality_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_tag_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
