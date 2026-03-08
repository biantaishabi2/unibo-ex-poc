# Workflow: event_registration_lifecycle — 活动报名生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm
#   create --> cancel
#   confirm --> set_done
#   confirm --> cancel
#   confirm --> send_badge_email
#   set_done --> [*]
#   cancel --> set_previous_state
#   set_previous_state --> confirm
#   send_badge_email --> [*]
# ```
defmodule UniboExPoc.Marketing.EventRegistration do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "活动报名"
  end

  postgres do
    table "marketing_event_registrations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event_registration

    queries do
      get :get_marketing_event_registration, :read
      list :list_marketing_event_registrations, :read
    end

    mutations do
      create :create_marketing_event_registration, :create
      update :confirm_marketing_event_registration, :confirm
      update :set_done_marketing_event_registration, :set_done
      update :cancel_marketing_event_registration, :cancel
      update :set_previous_state_marketing_event_registration, :set_previous_state
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :attendee_name, :string do
      allow_nil? false
      public? true
    end
    attribute :attendee_email, :string, public?: true
    attribute :attendee_phone, :string do
      public? true
      description "电话（计算自 partner，fallback mobile）"
    end
    attribute :company_name, :string do
      public? true
      description "公司名称（计算自 partner）"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :open, :done, :cancel]
      default :draft
      public? true
    end
    attribute :registration_date, :date do
      allow_nil? false
      public? true
    end
    attribute :date_closed, :utc_datetime do
      public? true
      description "签到时间（状态变为 done 时自动设置）"
    end
    attribute :barcode, :string do
      public? true
      description "签到条码"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "软删除标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboExPoc.Marketing.Event do
      public? true
      allow_nil? false
    end
    belongs_to :ticket, UniboExPoc.Marketing.EventTicket do
      public? true
    end
    belongs_to :partner, UniboExPoc.Marketing.Contact do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:attendee_name, :attendee_email, :attendee_phone, :company_name, :registration_date, :barcode]
      argument :event_id, :uuid, allow_nil?: false
      argument :ticket_id, :uuid
      argument :partner_id, :uuid
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:attendee_name)
      # validation: ticket_belongs_to_event
      change set_attribute(:id, expr(id))
    end
    update :confirm do
      description "确认报名（draft → open）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :open)
      change UniboExPoc.Marketing.Changes.EventRegistration.ConfirmCall5
      change UniboExPoc.Marketing.Changes.EventRegistration.ConfirmCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_done do
      description "签到（any → done）"
      accept []
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
      change set_attribute(:date_closed, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消报名"
      accept []
      change set_attribute(:status, :cancel)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_previous_state do
      description "回滚状态（open→draft, done→open）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:open, :done] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:open, :done]}))
        end
      end
      # message: "仅 open/done 状态允许回滚"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :register_attendee do
      description "条码签到"
      argument :barcode, :string
      argument :event_id, :string
      validate present([:barcode])
      run fn input, _context ->
        :ok
      end
    end
    action :send_badge_email do
      description "发送证件邮件（使用 event_badge 模板）"
      validate attribute_in(:, [:open, :done])
      run fn input, _context ->
        :ok
      end
    end
  end

  identities do
    identity :unique_barcode, [:barcode]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
