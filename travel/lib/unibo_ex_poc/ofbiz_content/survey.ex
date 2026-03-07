defmodule UniboExPoc.Ofbiz.Content.Survey do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_surveys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey

    queries do
      get :get_content_survey, :read
      list :list_content_surveys, :read
    end

    mutations do
      create :create_content_survey, :create
      update :update_content_survey, :update
      destroy :delete_content_survey, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :survey_id, :string, public?: true
    attribute :survey_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :submit_caption, :string, public?: true
    attribute :response_service, :string, public?: true
    attribute :is_anonymous, :boolean do
      public? true
      description "允许不登录就响应调研?"
    end
    attribute :allow_multiple, :boolean do
      public? true
      description "允许对此调研进行多次响应（如果为 Y），或仅单个答案（如果为 N）?"
    end
    attribute :allow_update, :boolean do
      public? true
      description "允许更改响应?"
    end
    attribute :acro_form_content_id, :string do
      public? true
      description "指向具有 AcroForm 的 PDF"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
