# Workflow: applicant_skill_write_flow — ApplicantSkill 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.ApplicantSkill do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "候选人技能关联（多对多中间表）"
  end

  postgres do
    table "hr_applicant_skills"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_applicant_skill

    queries do
      get :get_hr_applicant_skill, :read
      list :list_hr_applicant_skills, :read
    end

    mutations do
      create :create_hr_applicant_skill, :create
      update :update_hr_applicant_skill, :update
    end

  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :job_application, UniboExPoc.HR.JobApplication do
      public? true
      allow_nil? false
    end
    belongs_to :skill, UniboExPoc.HR.Skill do
      public? true
      allow_nil? false
    end
    belongs_to :skill_level, UniboExPoc.HR.SkillLevel do
      public? true
      allow_nil? false
    end
    belongs_to :skill_type, UniboExPoc.HR.SkillType do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept []
      argument :job_application_id, :uuid, allow_nil?: false
      argument :skill_id, :uuid, allow_nil?: false
      argument :skill_level_id, :uuid, allow_nil?: false
      argument :skill_type_id, :uuid, allow_nil?: false
      change manage_relationship(:job_application_id, :job_application, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_id, :skill, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_level_id, :skill_level, type: :append, on_lookup: :relate)
      change manage_relationship(:skill_type_id, :skill_type, type: :append, on_lookup: :relate)
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept []
      argument :skill_level_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_applicant_skill, [:job_application_id, :skill_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
