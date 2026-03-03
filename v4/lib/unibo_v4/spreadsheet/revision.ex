# Workflow: revision_commit_flow — 快照创建与修订提交流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create_snapshot
#   create_snapshot --> [*]
#   apply_revision --> [*]
# ```
defmodule UniboV4.Spreadsheet.Revision do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "spreadsheet_revisions"
    repo UniboV4.Repo
  end

  graphql do
    type :spreadsheet_revision

    queries do
      get :get_spreadsheet_revision, :read
      list :list_spreadsheet_revisions, :read
    end

    mutations do
      create :create_apply_revision_spreadsheet_revision, :apply_revision
      create :create_create_snapshot_spreadsheet_revision, :create_snapshot
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :document_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :commands, :string do
      allow_nil? false
      public? true
    end
    attribute :parent_revision_id, :string do
      allow_nil? false
      public? true
    end
    attribute :user_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:remote_revision, :revision_undone, :revision_redone, :snapshot]
      public? true
    end
    attribute :timestamp, :utc_datetime, public?: true
  end

  relationships do
    belongs_to :document, UniboV4.Spreadsheet.SpreadsheetDocument do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Spreadsheet.User do
      public? true
      allow_nil? false
    end
    belongs_to :parent_revision, UniboV4.Spreadsheet.Revision do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
    create :apply_revision do
      primary? true
      accept [:commands, :parent_revision_id, :type]
      argument :document_id, :integer, allow_nil?: false
      argument :user_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :current_revision_id, id)
        else
          changeset
        end
      end
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    create :create_snapshot do
      accept [:commands]
      argument :document_id, :integer, allow_nil?: false
      argument :user_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
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
  end

end
