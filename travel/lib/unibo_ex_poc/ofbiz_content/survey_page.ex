defmodule UniboExPoc.Ofbiz.Content.SurveyPage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_pages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_page

    queries do
      get :get_content_survey_page, :read
      list :list_content_survey_pages, :read
    end

    mutations do
      create :create_content_survey_page, :create
      update :update_content_survey_page, :update
      destroy :delete_content_survey_page, :destroy
    end

  end

  attributes do
    attribute :survey_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_page_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :page_name, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey, UniboExPoc.Ofbiz.Content.Survey do
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
