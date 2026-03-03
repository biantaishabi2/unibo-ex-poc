# Workflow: applicant_skill_write_flow — ApplicantSkill 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.ApplicantSkill do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_applicant_skills"
    repo UniboV4.Repo
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
    attribute :job_application_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :skill_id, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :job_application, UniboV4.HR.JobApplication do
      public? true
      allow_nil? false
    end
    belongs_to :skill, UniboV4.HR.Skill do
      public? true
      allow_nil? false
    end
    belongs_to :skill_level, UniboV4.HR.SkillLevel do
      public? true
      allow_nil? false
    end
    belongs_to :skill_type, UniboV4.HR.SkillType do
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
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept []
      argument :skill_level_id, :uuid
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_applicant_skill, [:job_application_id, :skill_id]
  end

end
