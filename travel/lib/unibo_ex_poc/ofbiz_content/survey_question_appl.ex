defmodule UniboExPoc.Ofbiz.Content.SurveyQuestionAppl do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_question_appls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_question_appl

    queries do
      get :get_content_survey_question_appl, :read
      list :list_content_survey_question_appls, :read
    end

    mutations do
      create :create_content_survey_question_appl, :create
      update :update_content_survey_question_appl, :update
      destroy :delete_content_survey_question_appl, :destroy
    end

  end

  attributes do
    attribute :survey_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_question_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :survey_page_seq_id, :string, public?: true
    attribute :survey_multi_resp_id, :string, public?: true
    attribute :survey_multi_resp_col_id, :string do
      public? true
      description "用于可选地将此问题关联到多响应集中的特定列；这样可以将单个问题关联到问题/列网格中的每个单元格；这对 AcroForm 往返很有用，其中目标 PDF 需要与每个单元格关联一个问题，或甚至同一问题应用不同的 externalFieldRef 值"
    end
    attribute :required_field, :boolean, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :external_field_ref, :string do
      public? true
      description "外部字段 ID/参考；用于 AcroForms 跟踪字段 ID"
    end
    attribute :with_survey_question_id, :string do
      public? true
      description "这两个 with* 字段用于指定此问题仅在已选择该选项时出现"
    end
    attribute :with_survey_option_seq_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey, UniboExPoc.Ofbiz.Content.Survey do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :survey_question, UniboExPoc.Ofbiz.Content.SurveyQuestion do
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
