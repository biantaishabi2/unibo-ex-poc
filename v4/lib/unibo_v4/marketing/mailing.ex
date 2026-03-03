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
defmodule UniboV4.Marketing.Mailing do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Marketing.Mailing.Notifier]

  postgres do
    table "marketing_mailings"
    repo UniboV4.Repo
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
    end
    attribute :subject, :string do
      allow_nil? false
      public? true
    end
    attribute :body_html, :string, public?: true
    attribute :preview, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :in_queue, :sending, :done, :cancelled]
      default :draft
      public? true
    end
    attribute :schedule_type, :atom do
      constraints one_of: [:now, :scheduled]
      public? true
    end
    attribute :schedule_date, :utc_datetime, public?: true
    attribute :sent_date, :utc_datetime, public?: true
    attribute :reply_to_mode, :atom do
      constraints one_of: [:update, :new]
      public? true
    end
    attribute :reply_to, :string, public?: true
    attribute :ab_testing_enabled, :boolean do
      default false
      public? true
    end
    attribute :ab_testing_pc, :integer, public?: true
    attribute :ab_testing_winner_selection, :atom do
      constraints one_of: [:opened, :clicked, :replied, :bounced]
      public? true
    end
    attribute :mailing_model_id, :string, public?: true
    attribute :mailing_domain, :string, public?: true
    attribute :next_departure_is_past, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      public? true
    end
    many_to_many :contact_lists, UniboV4.Marketing.MailingList do
      public? true
      through UniboV4.Marketing.MailingContactListLink
    end
    has_many :traces, UniboV4.Marketing.MailingTrace do
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
    update :launch do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:schedule_type, &DateTime.utc_now/0)
      change set_attribute(:status, :in_queue)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
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
    update :schedule do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :in_queue)
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
    update :put_in_queue do
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
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
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
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "草稿状态才允许编辑或取消"
      change set_attribute(:status, :draft)
      # TODO: 不支持的 change effect custom
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
    update :retry_failed do
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
    update :send_winner_mailing do
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
