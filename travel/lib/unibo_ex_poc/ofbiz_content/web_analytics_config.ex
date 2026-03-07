defmodule UniboExPoc.Ofbiz.Content.WebAnalyticsConfig do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_web_analytics_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_web_analytics_config

    queries do
      get :get_content_web_analytics_config, :read
      list :list_content_web_analytics_configs, :read
    end

    mutations do
      create :create_content_web_analytics_config, :create
      update :update_content_web_analytics_config, :update
      destroy :delete_content_web_analytics_config, :destroy
    end

  end

  attributes do
    attribute :web_site_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :web_analytics_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :web_analytics_code, :string do
      public? true
      description "在此处复制分析 javascript 代码，不包括开始和结束的 <script> 标签"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :web_analytics_type, UniboExPoc.Ofbiz.Content.WebAnalyticsType do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
