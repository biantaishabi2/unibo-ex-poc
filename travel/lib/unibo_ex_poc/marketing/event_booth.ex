# Workflow: event_booth_lifecycle — 展位生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> confirm
#   update --> confirm
#   confirm --> release
#   release --> [*]
# ```
defmodule UniboExPoc.Marketing.EventBooth do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "活动展位实例，可预订/确认"
  end

  postgres do
    table "marketing_event_booths"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event_booth

    queries do
      get :get_marketing_event_booth, :read
      list :list_marketing_event_booths, :read
    end

    mutations do
      create :create_marketing_event_booth, :create
      update :update_marketing_event_booth, :update
      update :confirm_marketing_event_booth, :confirm
      update :release_marketing_event_booth, :release
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "展位名称/编号"
    end
    attribute :state, :atom do
      constraints one_of: [:available, :unavailable]
      default :available
      public? true
      description "展位状态"
    end
    attribute :contact_name, :string do
      public? true
      description "租赁者姓名（从 partner 计算）"
    end
    attribute :contact_email, :string do
      public? true
      description "租赁者邮箱（从 partner 计算）"
    end
    attribute :contact_phone, :string do
      public? true
      description "租赁者电话（从 partner 计算）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboExPoc.Marketing.Event do
      public? true
      allow_nil? false
    end
    belongs_to :booth_category, UniboExPoc.Marketing.EventBoothCategory do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Marketing.Contact do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :contact_name, :contact_email, :contact_phone]
      argument :event_id, :uuid, allow_nil?: false
      argument :booth_category_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      change manage_relationship(:booth_category_id, :booth_category, type: :append, on_lookup: :relate)
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
      accept [:name, :contact_name, :contact_email, :contact_phone]
      argument :partner_id, :uuid
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
    update :confirm do
      description "确认展位预订（available → unavailable）"
      accept []
      argument :partner_id, :uuid, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :available do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :available}))
        end
      end
      # message: "只有可用状态的展位可以确认"
      change set_attribute(:state, :unavailable)
      change UniboExPoc.Marketing.Changes.EventBooth.ConfirmCall3
      change UniboExPoc.Marketing.Changes.EventBooth.ConfirmCall4
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
      description "释放展位（unavailable → available）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :unavailable do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :unavailable}))
        end
      end
      # message: "只有已预订状态的展位可以释放"
      change set_attribute(:state, :available)
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
