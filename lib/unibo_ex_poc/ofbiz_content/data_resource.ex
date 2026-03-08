defmodule UniboV4.Ofbiz.Content.DataResource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_data_resources"
    repo UniboV4.Repo
  end

  graphql do
    type :content_data_resource

    queries do
      get :get_content_data_resource, :read
      list :list_content_data_resources, :read
    end

    mutations do
      create :create_content_data_resource, :create
      update :update_content_data_resource, :update
      destroy :delete_content_data_resource, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :data_resource_id, :string, public?: true
    attribute :data_source_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :data_resource_name, :string, public?: true
    attribute :locale_string, :string, public?: true
    attribute :object_info, :string do
      public? true
      description "短文本的文本放在这里"
    end
    attribute :related_detail_id, :string do
      public? true
      description "根据 dataResourceTypeId，可以指向其他实体，如：调研、调研响应等"
    end
    attribute :is_public, :boolean do
      public? true
      description "设置为 Y 则任何人都可以下载，否则下载被限制"
    end
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :data_resource_type, UniboV4.Ofbiz.Content.DataResourceType do
      public? true
      attribute_type :string
    end
    belongs_to :data_template_type, UniboV4.Ofbiz.Content.DataTemplateType do
      public? true
      attribute_type :string
    end
    belongs_to :data_category, UniboV4.Ofbiz.Content.DataCategory do
      public? true
      attribute_type :string
    end
    belongs_to :mime_type, UniboV4.Ofbiz.Content.MimeType do
      public? true
      attribute_type :string
    end
    belongs_to :character_set, UniboV4.Ofbiz.Content.CharacterSet do
      public? true
      attribute_type :string
    end
    belongs_to :survey, UniboV4.Ofbiz.Content.Survey do
      public? true
      attribute_type :string
    end
    belongs_to :survey_response, UniboV4.Ofbiz.Content.SurveyResponse do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
