# Workflow: booth_lifecycle — 展位管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reserve
#   create --> destroy
#   reserve --> release
#   release --> reserve
#   release --> destroy
# ```
defmodule UniboV4.Events.EventBooth do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动展位，管理展览/博览会的展位分配"
  end

  postgres do
    table "events_event_booths"
    repo UniboV4.Repo
  end

  graphql do
    type :events_event_booth

    queries do
      get :get_events_event_booth, :read
      list :list_events_event_booths, :read
    end

    mutations do
      create :create_events_event_booth, :create
      update :update_events_event_booth, :update
      update :reserve_events_event_booth, :reserve
      update :release_events_event_booth, :release
      destroy :delete_events_event_booth, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :booth_number, :string do
      allow_nil? false
      public? true
      description "展位编号"
    end
    attribute :name, :string do
      public? true
      description "展位名称"
    end
    attribute :area, :decimal do
      public? true
      description "展位面积（平方米）"
    end
    attribute :rental_price, :decimal do
      default 0
      public? true
      description "租金"
    end
    attribute :currency_id, :string do
      default "CNY"
      public? true
      description "币种"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:available, :reserved, :occupied, :maintenance]
      default :available
      public? true
      description "展位状态"
    end
    attribute :reserved_at, :utc_datetime do
      public? true
      description "预定时间"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event, UniboV4.Events.Event do
      public? true
      allow_nil? false
    end
    belongs_to :tenant, UniboV4.Events.Party do
      public? true
      source_attribute :tenant_party_id
    end
    has_many :translations, UniboV4.Events.EventBoothTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:event_id, :booth_number, :name, :area, :rental_price, :currency_id, :notes]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:booth_number)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :area, :rental_price, :notes]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reserve do
      description "预定展位（available -> reserved）"
      argument :tenant_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :available do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :available}))
        end
      end
      # message: "只有可用状态的展位可以预定"
      # skipped: validate present :tenant_id (incompatible with bulk update atomic path)
      change set_attribute(:status, :reserved)
      change UniboV4.Events.Changes.EventBooth.ComputeReservedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :release do
      description "释放展位（reserved/occupied -> available）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:reserved, :occupied] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:reserved, :occupied]}))
        end
      end
      # message: "只有已预定或已占用的展位可以释放"
      change set_attribute(:status, :available)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_event_booth_number, [:event_id, :booth_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
