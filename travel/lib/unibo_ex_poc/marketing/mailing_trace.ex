# Workflow: mailing_trace_flow — 邮件追踪记录流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Marketing.MailingTrace do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "邮件追踪记录（每封邮件一条）"
  end

  postgres do
    table "marketing_mailing_traces"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_mailing_trace

    queries do
      get :get_marketing_mailing_trace, :read
      list :list_marketing_mailing_traces, :read
    end

    mutations do
      create :create_marketing_mailing_trace, :create
      update :update_marketing_mailing_trace, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:outgoing, :sent, :open, :reply, :bounce, :error, :cancel]
      default :outgoing
      public? true
      description "追踪状态"
    end
    attribute :sent_datetime, :utc_datetime do
      public? true
      description "发送时间"
    end
    attribute :open_datetime, :utc_datetime do
      public? true
      description "打开时间"
    end
    attribute :links_click_datetime, :utc_datetime do
      public? true
      description "链接点击时间"
    end
    attribute :reply_datetime, :utc_datetime do
      public? true
      description "回复时间"
    end
    attribute :failure_type, :string do
      public? true
      description "失败分类"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mailing, UniboExPoc.Marketing.Mailing do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:status]
      argument :mailing_id, :uuid, allow_nil?: false
      change manage_relationship(:mailing_id, :mailing, type: :append, on_lookup: :relate)
      validate present(:status)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:status, :sent_datetime, :open_datetime, :links_click_datetime, :reply_datetime, :failure_type]
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
