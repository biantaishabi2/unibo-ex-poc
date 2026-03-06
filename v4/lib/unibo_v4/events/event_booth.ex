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
    otp_app: :unibo_v4,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :name, :string, public?: true
    attribute :area, :decimal, public?: true
    attribute :rental_price, :decimal do
      default 0
      public? true
    end
    attribute :currency_id, :string do
      default "CNY"
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:available, :reserved, :occupied, :maintenance]
      default :available
      public? true
    end
    attribute :tenant_id, :uuid, public?: true
    attribute :reserved_at, :utc_datetime, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Events.Event do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboV4.Events.EventBoothTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:booth_number, :name, :area, :rental_price, :currency_id, :notes]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:booth_number)
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
      accept [:name, :area, :rental_price, :notes]
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
    update :reserve do
      accept [:tenant_id]
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
      # TODO: 跨实体聚合表达式暂不支持
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
    update :release do
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
    identity :unique_event_booth_number, [:event_id, :booth_number]
  end

end
