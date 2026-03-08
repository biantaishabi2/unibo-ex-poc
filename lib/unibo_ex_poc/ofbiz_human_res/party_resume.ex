defmodule UniboV4.Ofbiz.HumanRes.PartyResume do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_party_resumes"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_party_resume

    queries do
      get :get_human_res_party_resume, :read
      list :list_human_res_party_resumes, :read
    end

    mutations do
      create :create_human_res_party_resume, :create
      update :update_human_res_party_resume, :update
      destroy :delete_human_res_party_resume, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :resume_id, :string do
      public? true
      description "简历编号"
    end
    attribute :resume_date, :utc_datetime do
      public? true
      description "简历日期"
    end
    attribute :resume_text, :string do
      public? true
      description "简历文本"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :content, UniboV4.Ofbiz.HumanRes.Content do
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
