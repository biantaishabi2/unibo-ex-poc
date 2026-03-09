# Workflow: sign_template_write_flow — 签名模板写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   archive --> [*]
#   activate --> [*]
# ```
defmodule UniboExPoc.Sign.SignTemplate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "签名模板，包含上传的 PDF 文件及签名字段定义"
  end

  postgres do
    table "sign_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sign_sign_template

    queries do
      get :get_sign_sign_template, :read
      list :list_sign_sign_templates, :read
    end

    mutations do
      create :create_sign_sign_template, :create
      update :update_sign_sign_template, :update
      update :archive_sign_sign_template, :archive
      update :activate_sign_sign_template, :activate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "模板名称"
    end
    attribute :document, :string do
      allow_nil? false
      public? true
      description "上传的 PDF 文件（attachment）"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :archived]
      default :active
      public? true
      description "模板状态"
    end
    attribute :tag_ids, {:array, :string} do
      public? true
      description "分类标签列表"
    end
    attribute :is_sharing, :boolean do
      default false
      public? true
      description "是否允许其他用户使用此模板"
    end
    attribute :authorized_ids, {:array, :string} do
      public? true
      description "当 is_sharing=true 时限定可用用户列表"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :num_pages, :integer, expr(pdf_page_count(document))
    calculate :sign_item_count, :integer, expr(count(sign_items, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :responsible, UniboExPoc.Sign.Party do
      public? true
      source_attribute :responsible_party_id
    end
    has_many :sign_items, UniboExPoc.Sign.SignItem do
      public? true
      source_attribute :responsible_party_id
      destination_attribute :template_id
    end
    has_many :sign_requests, UniboExPoc.Sign.SignRequest do
      public? true
      source_attribute :responsible_party_id
      destination_attribute :template_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :document, :tag_ids, :is_sharing, :authorized_ids]
      argument :responsible_id, :uuid
      argument :sign_items, {:array, :string}
      change manage_relationship(:sign_items, :sign_items, type: :create)
      validate present(:name)
      validate present(:document)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :document, :tag_ids, :is_sharing, :authorized_ids]
      argument :sign_items, {:array, :map}, default: []
      change manage_relationship(:sign_items, :sign_items, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档模板"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态可以归档"
      change set_attribute(:status, :archived)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "启用模板"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :archived do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :archived}))
        end
      end
      # message: "只有已归档状态可以启用"
      change set_attribute(:status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
