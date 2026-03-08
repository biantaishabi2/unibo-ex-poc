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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.ELearning,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboV4.ELearning.Slide.Notifier]

  resource do
    description "课程内容项，支持文章、视频、文档、信息图、测验等类型"
  end

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
      description "内容项名称"
    end
    attribute :slide_category, :atom do
      allow_nil? false
      constraints one_of: [:infographic, :article, :document, :video, :quiz]
      public? true
      description "内容类别"
    end
    attribute :is_category, :boolean do
      default false
      public? true
      description "是否为章节标题（分类头）"
    end
    attribute :sequence, :integer do
      default 0
      public? true
      description "排序序号"
    end
    attribute :is_published, :boolean do
      default false
      public? true
      description "是否已发布"
    end
    attribute :date_published, :utc_datetime do
      public? true
      description "发布时间"
    end
    attribute :is_preview, :boolean do
      default false
      public? true
      description "非会员是否可预览"
    end
    attribute :html_content, :string do
      public? true
      description "文章内容（article 类型专用）"
    end
    attribute :url, :string do
      public? true
      description "外部链接（video/document 类型专用）"
    end
    attribute :completion_time, :decimal do
      public? true
      description "预计完成时间（小时）"
    end
    attribute :likes, :integer do
      default 0
      public? true
      description "点赞数"
    end
    attribute :dislikes, :integer do
      default 0
      public? true
      description "踩数"
    end
    attribute :total_views, :integer do
      default 0
      public? true
      description "总浏览次数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_new_slide, :boolean, expr(days_since(date_published) <= 7)
    calculate :can_self_mark_completed, :boolean, expr(slide_category != "quiz")
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
      source_attribute :category_id
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
      # validation: content_exclusivity — html_content 和 url 不能同时存在，article 类型使用 html_content，video/document 使用 url
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :is_preview, :html_content, :url, :completion_time]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布内容项，触发通知并设置发布时间"
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
      change UniboV4.ELearning.Changes.Slide.ComputeDatePublished
      change UniboV4.ELearning.Changes.Slide.PublishCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unpublish do
      description "取消发布，触发所有 Enrollment 完成度重算（分母变化）"
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
      change UniboV4.ELearning.Changes.Slide.UnpublishCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:child_slides, :progress_records]
  end

end
