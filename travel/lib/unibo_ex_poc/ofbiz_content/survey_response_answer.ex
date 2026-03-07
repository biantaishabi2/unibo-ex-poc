defmodule UniboExPoc.Ofbiz.Content.SurveyResponseAnswer do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_response_answers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_response_answer

    queries do
      get :get_content_survey_response_answer, :read
      list :list_content_survey_response_answers, :read
    end

    mutations do
      create :create_content_survey_response_answer, :create
      update :update_content_survey_response_answer, :update
      destroy :delete_content_survey_response_answer, :destroy
    end

  end

  attributes do
    attribute :survey_response_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_question_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_multi_resp_col_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "需要这个来支持不同多响应列的多个响应；如果不属于多响应，则为 _NA_"
    end
    attribute :survey_multi_resp_id, :string do
      public? true
      description "这不是主键的一部分，但应填充以便可以更轻松地查找 SurveyMultiRespColumn"
    end
    attribute :boolean_response, :boolean, public?: true
    attribute :currency_response, :decimal, public?: true
    attribute :float_response, :float, public?: true
    attribute :numeric_response, :integer, public?: true
    attribute :text_response, :string, public?: true
    attribute :survey_option_seq_id, :string, public?: true
    attribute :answered_date, :utc_datetime, public?: true
    attribute :amount_base, :decimal, public?: true
    attribute :amount_base_uom_id, :string, public?: true
    attribute :weight_factor, :float, public?: true
    attribute :duration, :integer, public?: true
    attribute :duration_uom_id, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey_response, UniboExPoc.Ofbiz.Content.SurveyResponse do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :survey_question, UniboExPoc.Ofbiz.Content.SurveyQuestion do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :content, UniboExPoc.Ofbiz.Content.Content do
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
