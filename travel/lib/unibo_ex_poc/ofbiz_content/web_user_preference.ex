defmodule UniboExPoc.Ofbiz.Content.WebUserPreference do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_web_user_preferences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_web_user_preference

    queries do
      get :get_content_web_user_preference, :read
      list :list_content_web_user_preferences, :read
    end

    mutations do
      create :create_content_web_user_preference, :create
      update :update_content_web_user_preference, :update
      destroy :delete_content_web_user_preference, :destroy
    end

  end

  attributes do
    attribute :user_login_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :visit_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "能够为当前会话中未登录的用户保存偏好设置"
    end
    attribute :web_preference_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :web_preference_type, UniboExPoc.Ofbiz.Content.WebPreferenceType do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
