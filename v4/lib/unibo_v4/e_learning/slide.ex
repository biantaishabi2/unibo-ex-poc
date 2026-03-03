# Workflow: slide_lifecycle — 内容项生命周期（创建→发布→取消发布/删除）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   create --> destroy
#   update --> update
#   update --> publish
#   update --> destroy
#   publish --> unpublish
#   publish --> destroy
#   unpublish --> update
#   unpublish --> publish
#   unpublish --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.ELearning.Slide do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.ELearning.Slide.Notifier]

  postgres do
    table "e_learning_slides"
    repo UniboV4.Repo
  end

  graphql do
    type :e_learning_slide

    queries do
      get :get_e_learning_slide, :read
      list :list_e_learning_slides, :read
    end

    mutations do
      create :create_e_learning_slide, :create
      update :update_e_learning_slide, :update
      update :publish_e_learning_slide, :publish
      update :unpublish_e_learning_slide, :unpublish
      destroy :delete_e_learning_slide, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :slide_category, :atom do
      allow_nil? false
      constraints one_of: [:infographic, :article, :document, :video, :quiz]
      public? true
    end
    attribute :is_category, :boolean do
      default false
      public? true
    end
    attribute :sequence, :integer do
      default 0
      public? true
    end
    attribute :is_published, :boolean do
      default false
      public? true
    end
    attribute :date_published, :utc_datetime, public?: true
    attribute :is_preview, :boolean do
      default false
      public? true
    end
    attribute :html_content, :string, public?: true
    attribute :url, :string, public?: true
    attribute :completion_time, :decimal, public?: true
    attribute :likes, :integer do
      default 0
      public? true
    end
    attribute :dislikes, :integer do
      default 0
      public? true
    end
    attribute :total_views, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_new_slide
    # TODO: 不支持的 calculation 表达式 :can_self_mark_completed
  end

  relationships do
    belongs_to :channel, UniboV4.ELearning.Course do
      public? true
      allow_nil? false
    end
    belongs_to :category, UniboV4.ELearning.Slide do
      public? true
    end
    has_many :child_slides, UniboV4.ELearning.Slide do
      public? true
      destination_attribute :category_id
    end
    has_many :progress_records, UniboV4.ELearning.SlideProgress do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :slide_category, :is_category, :sequence, :is_preview, :html_content, :url, :completion_time]
      argument :channel_id, :uuid, allow_nil?: false
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      validate present(:name)
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
      accept [:name, :sequence, :is_preview, :html_content, :url, :completion_time]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :publish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_published)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_published, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "内容项已处于发布状态"
      change set_attribute(:is_published, true)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的 change effect recompute_parent
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
    update :unpublish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_published)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_published, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "内容项未发布，无法取消发布"
      change set_attribute(:is_published, false)
      # TODO: 不支持的 change effect recompute_parent
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
