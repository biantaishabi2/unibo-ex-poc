# Workflow: workflow_rule_execution_flow — 工作流规则配置、执行与回收流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   execute --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.WorkflowRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_workflow_rules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :note, :string, public?: true
    attribute :condition_type, :atom do
      allow_nil? false
      constraints one_of: [:criteria, :domain]
      public? true
    end
    attribute :domain, :string, public?: true
    attribute :create_model, :atom do
      constraints one_of: [:link_to_record, :vendor_bill, :customer_invoice, :vendor_refund, :customer_refund, :sign_direct, :sign_request, :product, :project_task]
      public? true
    end
    attribute :activity_option, :atom do
      constraints one_of: [:nothing, :mark_done, :schedule]
      public? true
    end
    attribute :activity_summary, :string, public?: true
    attribute :activity_date_deadline_range, :integer, public?: true
    attribute :activity_note, :string, public?: true
    attribute :trigger_type, :atom do
      constraints one_of: [:manual, :on_upload, :on_update, :scheduled]
      default :manual
      public? true
    end
    attribute :sequence, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
    many_to_many :required_tags, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.WorkflowRuleRequiredTagLink
    end
    many_to_many :excluded_tags, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.WorkflowRuleExcludedTagLink
    end
    many_to_many :tag_actions, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.WorkflowRuleTagActionLink
    end
    many_to_many :remove_tags, UniboV4.Documents.Tag do
      public? true
      through UniboV4.Documents.WorkflowRuleRemoveTagLink
    end
    belongs_to :partner, UniboV4.Documents.Contact do
      public? true
    end
    belongs_to :owner, UniboV4.Documents.User do
      public? true
    end
    belongs_to :folder_action, UniboV4.Documents.Document do
      public? true
    end
    belongs_to :partner_action, UniboV4.Documents.Contact do
      public? true
    end
    belongs_to :owner_action, UniboV4.Documents.User do
      public? true
    end
    belongs_to :activity_type, UniboV4.Documents.ActivityType do
      public? true
    end
    belongs_to :activity_user, UniboV4.Documents.User do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :note, :condition_type, :domain, :create_model, :activity_option, :activity_summary, :activity_date_deadline_range, :activity_note, :trigger_type, :sequence]
      argument :folder_id, :uuid, allow_nil?: false
      change manage_relationship(:folder_id, :folder, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:folder_id)
      validate present(:condition_type)
      validate present(:activity_type_id)
      # message: "当 activity_option=schedule 时必须指定活动类型"
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
      accept [:name, :note, :condition_type, :domain, :create_model, :activity_option, :activity_summary, :activity_date_deadline_range, :activity_note, :trigger_type, :sequence]
      # skipped: validate present :activity_type_id (incompatible with bulk update atomic path)
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
    update :execute do
      argument :document_ids, {:array, :string}, allow_nil?: false
      # skipped: validate present :activity_type_id (incompatible with bulk update atomic path)
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

end
