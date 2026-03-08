defmodule UniboExPoc.Ofbiz.HumanRes.PartySkill do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_party_skills"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_party_skill

    queries do
      get :get_human_res_party_skill, :read
      list :list_human_res_party_skills, :read
    end

    mutations do
      create :create_human_res_party_skill, :create
      update :update_human_res_party_skill, :update
      destroy :delete_human_res_party_skill, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :years_experience, :integer, public?: true
    attribute :rating, :integer, public?: true
    attribute :skill_level, :integer, public?: true
    attribute :started_using_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :skill_type, UniboExPoc.Ofbiz.HumanRes.SkillType do
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
