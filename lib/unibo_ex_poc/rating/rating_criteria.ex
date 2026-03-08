# Workflow: rating_criteria_lifecycle — 评价维度维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reorder
#   create --> destroy
#   update --> reorder
#   update --> destroy
#   reorder --> update
#   reorder --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Rating.RatingCriteria do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "评价维度（质量、交期、服务态度等），全新建模"
  end

  postgres do
    table "rating_criterias"
    repo UniboV4.Repo
  end

  graphql do
    type :rating_rating_criteria

    queries do
      get :get_rating_rating_criteria, :read
      list :list_rating_rating_criterias, :read
    end

    mutations do
      create :create_rating_rating_criteria, :create
      update :update_rating_rating_criteria, :update
      update :reorder_rating_rating_criteria, :reorder
      destroy :delete_rating_rating_criteria, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "维度名称（如：质量、交期、服务态度）"
    end
    attribute :description, :string do
      public? true
      description "维度说明"
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "维度编码（如 quality、delivery、service）"
    end
    attribute :weight, :decimal do
      default 1.0
      public? true
      description "权重（用于加权平均计算）"
    end
    attribute :sort_order, :integer do
      default 0
      public? true
      description "排序序号"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :rating_type, UniboV4.Rating.RatingType do
      public? true
    end
    has_many :scores, UniboV4.Rating.RatingScore do
      public? true
      source_attribute :rating_type_id
      destination_attribute :criteria_id
    end
    has_many :translations, UniboV4.Rating.RatingCriteriaTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :code, :weight, :sort_order, :active]
      argument :rating_type_id, :uuid, allow_nil?: false
      validate present(:name)
      validate present(:code)
      validate present(:rating_type_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :weight, :sort_order, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reorder do
      description "调整维度排序"
      accept [:sort_order]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:weight, greater_than: 0)
  end

  identities do
    identity :unique_code_per_type, [:rating_type_id, :code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:scores]
  end

end
