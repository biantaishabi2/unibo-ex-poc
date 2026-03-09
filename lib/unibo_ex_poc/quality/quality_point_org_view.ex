defmodule UniboExPoc.Quality.QualityPointOrgView do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "质检点按组织的配置切面——同一 QualityPoint 在不同组织有不同检验标准"
  end

  postgres do
    table "quality_point_org_views"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_point_org_view

    queries do
      get :get_quality_quality_point_org_view, :read
      list :list_quality_quality_point_org_views, :read
    end

    mutations do
      create :create_quality_quality_point_org_view, :create
      update :update_quality_quality_point_org_view, :update
      destroy :delete_quality_quality_point_org_view, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sampling_rate, :decimal do
      public? true
      description "抽检比例"
    end
    attribute :is_mandatory, :boolean do
      default true
      public? true
      description "是否强制检查"
    end
    attribute :custom_norm_value, :decimal do
      public? true
      description "该组织的自定义标准值（覆盖 QualityPoint 的默认值）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :quality_point, UniboExPoc.Quality.QualityPoint do
      public? true
      allow_nil? false
    end
    belongs_to :party, UniboExPoc.Quality.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:sampling_rate, :is_mandatory, :custom_norm_value]
      argument :quality_point_id, :uuid, allow_nil?: false
      argument :party_id, :uuid, allow_nil?: false
      change manage_relationship(:quality_point_id, :quality_point, type: :append, on_lookup: :relate)
      change manage_relationship(:party_id, :party, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:sampling_rate, :is_mandatory, :custom_norm_value]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
