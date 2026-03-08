# Workflow: incoming_number_lifecycle — 入站号码创建、目标绑定变更与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   bind_destination --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.IncomingNumber do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "组织的入站电话号码（DID），通过 5 个可选 FK 绑定到拨号计划或直接转分机/语音信箱/队列/会议室"
  end

  postgres do
    table "io_t_incoming_numbers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_incoming_number

    queries do
      get :get_io_t_incoming_number, :read
      list :list_io_t_incoming_numbers, :read
    end

    mutations do
      create :create_io_t_incoming_number, :create
      update :update_io_t_incoming_number, :update
      update :bind_destination_io_t_incoming_number, :bind_destination
      destroy :delete_io_t_incoming_number, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :number, :string do
      allow_nil? false
      public? true
      description "E.164 格式号码"
    end
    attribute :name, :string do
      public? true
      description "显示名称"
    end
    attribute :country_code, :string do
      public? true
      description "国家码"
    end
    attribute :city, :string do
      public? true
      description "城市"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否激活"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :dial_plan, UniboExPoc.IoT.DialPlan do
      public? true
      attribute_type :integer
    end
    belongs_to :extension_user, UniboExPoc.IoT.Party do
      public? true
      source_attribute :extension_user_party_id
    end
    belongs_to :voicemail_target, UniboExPoc.IoT.Voicemail do
      public? true
      source_attribute :voicemail_id
      attribute_type :integer
    end
    belongs_to :call_queue, UniboExPoc.IoT.CallQueue do
      public? true
      source_attribute :queue_id
      attribute_type :integer
    end
    belongs_to :conference_room, UniboExPoc.IoT.ConferenceRoom do
      public? true
      attribute_type :integer
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:number, :name, :country_code, :city, :is_active, :org_id]
      argument :dial_plan_id, :integer
      argument :extension_user_id, :integer
      argument :voicemail_id, :integer
      argument :queue_id, :integer
      argument :conference_room_id, :integer
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:number)
      validate present(:org_id)
      validate present([:dial_plan_id, :queue_id, :user_id, :voicemail_id, :conference_room_id], exactly: 1)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :country_code, :city, :is_active]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :bind_destination do
      description "变更入站号码的目标绑定"
      argument :dial_plan_id, :integer
      argument :extension_user_id, :integer
      argument :voicemail_id, :integer
      argument :queue_id, :integer
      argument :conference_room_id, :integer
      # skipped: validate exactly_one_of : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_number, [:number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
