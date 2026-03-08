# Workflow: revision_commit_flow — 快照创建与修订提交流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create_snapshot
#   create_snapshot --> [*]
#   apply_revision --> [*]
# ```
defmodule UniboExPoc.Spreadsheet.Revision do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "修订历史，基于 OT（Operational Transformation）实现多人协作编辑的冲突解决"
  end

  postgres do
    table "spreadsheet_revisions"
    repo UniboExPoc.Repo
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
      description "修订 ID（UUID，即 nextRevisionId）"
    end
    attribute :commands, :string do
      allow_nil? false
      public? true
      description "OT 操作命令列表"
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:remote_revision, :revision_undone, :revision_redone, :snapshot]
      public? true
      description "修订类型（创建时确定，不可变更）"
    end
    attribute :timestamp, :utc_datetime do
      public? true
      description "时间戳"
    end
  end

  relationships do
    belongs_to :document, UniboExPoc.Spreadsheet.SpreadsheetDocument do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :user, UniboExPoc.Spreadsheet.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :parent_revision, UniboExPoc.Spreadsheet.Revision do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :update]
    create :apply_revision do
      description "提交新修订（服务端验证 parent_revision_id 后接受）"
      primary? true
      accept [:commands, :parent_revision_id, :type]
      argument :document_id, :integer, allow_nil?: false
      argument :user_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      # validation: parent_revision_match — parent_revision_id 与文档当前修订不一致，需客户端回滚+变换+重提
      # validation: update_document_revision
      # validation: conflict_on_mismatch
      # validation: max_revision_retention
      # validation: undo_creates_revision
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
      description "创建完整文档快照修订，用于加速后续加载"
      accept [:commands]
      argument :document_id, :integer, allow_nil?: false
      argument :user_id, :integer, allow_nil?: false
      change manage_relationship(:document_id, :document, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      # validation: snapshot_contains_full_state
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
