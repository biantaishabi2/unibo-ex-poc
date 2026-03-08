defmodule UniboV4.Ofbiz.Content.SurveyMultiRespColumn do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_multi_resp_columns"
    repo UniboV4.Repo
  end

  graphql do
    type :content_survey_multi_resp_column

    queries do
      get :get_content_survey_multi_resp_column, :read
      list :list_content_survey_multi_resp_columns, :read
    end

    mutations do
      create :create_content_survey_multi_resp_column, :create
      update :update_content_survey_multi_resp_column, :update
      destroy :delete_content_survey_multi_resp_column, :destroy
    end

  end

  attributes do
    attribute :survey_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_multi_resp_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_multi_resp_col_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :column_title, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
