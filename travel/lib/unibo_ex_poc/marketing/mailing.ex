# Workflow: mailing_delivery_flow — 群发邮件投递流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   schedule --> [*]
#   put_in_queue --> [*]
#   launch --> [*]
#   retry_failed --> [*]
# ```
defmodule UniboExPoc.Marketing.Mailing do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Marketing.Mailing.Notifier]

  resource do
    description "群发邮件"
  end

  postgres do
    table "marketing_mailings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_mailing

    queries do
      get :get_marketing_mailing, :read
      list :list_marketing_mailings, :read
    end

    mutations do
      create :create_marketing_mailing, :create
      update :update_marketing_mailing, :update
      update :launch_marketing_mailing, :launch
      update :schedule_marketing_mailing, :schedule
      update :put_in_queue_marketing_mailing, :put_in_queue
      update :cancel_marketing_mailing, :cancel
      update :retry_failed_marketing_mailing, :retry_failed
      update :send_winner_mailing_marketing_mailing, :send_winner_mailing
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "邮件主题"
    end
    attribute :subject, :string do
      allow_nil? false
      public? true
      description "邮件标题"
    end
    attribute :body_html, :string do
      public? true
      description "HTML 正文"
    end
    attribute :preview, :string do
      public? true
      description "预览文本（prepend to body）"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :in_queue, :sending, :done, :cancelled]
      default :draft
      public? true
    end
    attribute :schedule_type, :atom do
      constraints one_of: [:now, :scheduled]
      public? true
      description "发送类型"
    end
    attribute :schedule_date, :utc_datetime do
      public? true
      description "计划发送时间"
    end
    attribute :sent_date, :utc_datetime do
      public? true
      description "实际发送时间"
    end
    attribute :reply_to_mode, :atom do
      constraints one_of: [:update, :new]
      public? true
      description "回复模式（update=线程追加，new=指定地址）"
    end
    attribute :reply_to, :string do
      public? true
      description "回复地址（reply_to_mode=new 时）"
    end
    attribute :ab_testing_enabled, :boolean do
      default false
      public? true
      description "是否启用 A/B 测试"
    end
    attribute :ab_testing_pc, :integer do
      public? true
      description "A/B 测试百分比（1-100）"
    end
    attribute :ab_testing_winner_selection, :atom do
      constraints one_of: [:opened, :clicked, :replied, :bounced]
      public? true
      description "A/B 测试胜出指标"
    end
    attribute :mailing_model_id, :string do
      public? true
      description "目标模型（mailing.contact / event.registration 等）"
    end
    attribute :mailing_domain, :string do
      public? true
      description "收件人过滤域（JSON）"
    end
    attribute :next_departure_is_past, :boolean do
      default false
      public? true
      description "标记超期的 scheduled 邮件"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboExPoc.Marketing.Campaign do
      public? true
    end
    many_to_many :contact_lists, UniboExPoc.Marketing.MailingList do
      public? true
      through UniboExPoc.Marketing.MailingContactListLink
    end
    has_many :traces, UniboExPoc.Marketing.MailingTrace do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :subject, :body_html, :preview, :reply_to_mode, :reply_to, :ab_testing_enabled, :ab_testing_pc, :ab_testing_winner_selection, :mailing_model_id, :mailing_domain]
      argument :campaign_id, :uuid
      argument :contact_list_ids, {:array, :string}
      validate present(:name)
      validate present(:subject)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :subject, :body_html, :preview, :schedule_date, :reply_to_mode, :reply_to, :ab_testing_enabled, :ab_testing_pc, :ab_testing_winner_selection, :mailing_domain]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :launch do
      description "立即发送（设 schedule_type=now，调 put_in_queue）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送或排队"
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:schedule_type, &DateTime.utc_now/0)
      change set_attribute(:status, :in_queue)
      change UniboExPoc.Marketing.Changes.Mailing.LaunchCall5
      change UniboExPoc.Marketing.Changes.Mailing.LaunchCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :schedule do
      description "定时发送"
      accept [:schedule_date]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送或排队"
      # skipped: validate compare :schedule_date (incompatible with bulk update atomic path)
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:status, :in_queue)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :put_in_queue do
      description "放入发送队列"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发送或排队"
      change set_attribute(:status, :in_queue)
      change UniboExPoc.Marketing.Changes.Mailing.PutInQueueCall5
      change UniboExPoc.Marketing.Changes.Mailing.PutInQueueCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消发送，回退到草稿"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change set_attribute(:status, :draft)
      change UniboExPoc.Marketing.Changes.Mailing.CancelCall4
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :retry_failed do
      description "重试失败邮件，按 1000 批次重新入队"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :send_winner_mailing do
      description "A/B 测试发送胜出版本"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :done do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :done}))
        end
      end
      # message: "仅已结束批次允许发送 A/B 胜出版本"
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
