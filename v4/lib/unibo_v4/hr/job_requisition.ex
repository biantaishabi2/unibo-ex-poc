# Workflow: requisition_filled_flow — 招聘需求发布并完成流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   open --> [*]
#   close --> [*]
# ```
# Workflow: requisition_cancel_flow — 招聘需求发布后取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   open --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.HR.JobRequisition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.HR.JobRequisition.Notifier]

  postgres do
    table "hr_job_requisitions"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :requisition_number, :string do
      allow_nil? false
      public? true
    end
    attribute :job_title, :string do
      allow_nil? false
      public? true
    end
    attribute :headcount, :integer do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :open, :in_progress, :filled, :cancelled]
      default :draft
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
      public? true
    end
    attribute :description, :string, public?: true
    attribute :requirements, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department do
      public? true
    end
    has_many :applications, UniboV4.HR.JobApplication do
      public? true
      destination_attribute :requisition_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:requisition_number, :job_title, :headcount, :priority, :description, :requirements]
      argument :department_id, :uuid
      validate present(:requisition_number)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :open do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      change set_attribute(:status, :open)
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
    update :close do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:open, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:open, :in_progress]}))
        end
      end
      # message: "只有已发布或进行中状态可以关闭"
      change set_attribute(:status, :filled)
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
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :open, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :open, :in_progress]}))
        end
      end
      # message: "已关闭或已取消的不能再取消"
      change set_attribute(:status, :cancelled)
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

  validations do
    validate compare(:headcount, greater_than: 0)
  end

  identities do
    identity :unique_requisition_number, [:requisition_number]
  end

end
