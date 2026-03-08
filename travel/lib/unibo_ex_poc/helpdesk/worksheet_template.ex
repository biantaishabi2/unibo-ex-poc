# Workflow: worksheet_template_management — 工作表模板管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Helpdesk.WorksheetTemplate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工作表模板，定义现场服务填写表单的结构"
  end

  postgres do
    table "helpdesk_worksheet_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_worksheet_template

    queries do
      get :get_helpdesk_worksheet_template, :read
      list :list_helpdesk_worksheet_templates, :read
    end

    mutations do
      create :create_helpdesk_worksheet_template, :create
      update :update_helpdesk_worksheet_template, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "模板名称"
    end
    attribute :description, :string do
      public? true
      description "模板描述"
    end
    attribute :color, :integer do
      allow_nil? false
      default 0
      public? true
      description "Kanban 颜色索引"
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
      description "排序权重"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :service_orders, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
      destination_attribute :worksheet_template_id
    end
    has_many :worksheets, UniboExPoc.Helpdesk.Worksheet do
      public? true
      destination_attribute :template_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :color, :sequence]
      validate present(:name)
      # message: "模板名称必填"
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
      accept [:name, :description, :color, :sequence]
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
    identity :unique_worksheet_template_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
