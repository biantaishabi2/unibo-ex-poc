# Workflow: recycle_model_lifecycle — 回收规则维护与执行流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> recycle_records_action
#   create --> cron_recycle
#   create --> destroy
#   update --> update
#   update --> recycle_records_action
#   update --> cron_recycle
#   update --> destroy
#   recycle_records_action --> update
#   recycle_records_action --> cron_recycle
#   recycle_records_action --> destroy
#   cron_recycle --> update
#   cron_recycle --> recycle_records_action
#   cron_recycle --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.DataRecycle.RecycleModel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.DataRecycle,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "data_recycle_recycle_models"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :res_model_name, :string do
      allow_nil? false
      public? true
    end
    attribute :domain, :string, public?: true
    attribute :time_field, :string do
      allow_nil? false
      public? true
    end
    attribute :time_field_delta, :integer do
      allow_nil? false
      default 1
      public? true
    end
    attribute :time_field_delta_unit, :atom do
      constraints one_of: [:days, :weeks, :months, :years]
      default :months
      public? true
    end
    attribute :recycle_mode, :atom do
      constraints one_of: [:manual, :automatic]
      default :manual
      public? true
    end
    attribute :recycle_action, :atom do
      constraints one_of: [:archive, :delete]
      default :archive
      public? true
    end
    attribute :include_archived, :boolean do
      default false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :notify_frequency, :integer do
      default 1
      public? true
    end
    attribute :notify_frequency_period, :atom do
      constraints one_of: [:days, :weeks, :months]
      default :weeks
      public? true
    end
    attribute :last_notification, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :records_to_recycle_count
  end

  relationships do
    has_many :recycle_records, UniboV4.DataRecycle.RecycleRecord do
      public? true
    end
    many_to_many :notify_users, UniboV4.DataRecycle.ResUser do
      public? true
      through UniboV4.DataRecycle.RecycleModelNotifyUser
      destination_attribute_on_join_resource :user_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :res_model_name, :domain, :time_field, :time_field_delta, :time_field_delta_unit, :recycle_mode, :recycle_action, :include_archived, :active, :notify_frequency, :notify_frequency_period]
      validate present(:name)
      validate present(:res_model_name)
      validate present(:time_field)
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
      accept [:name, :res_model_name, :domain, :time_field, :time_field_delta, :time_field_delta_unit, :recycle_mode, :recycle_action, :include_archived, :active, :notify_frequency, :notify_frequency_period]
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
    update :recycle_records_action do
      accept []
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
    update :cron_recycle do
      accept []
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

  validations do
    # TODO: 不支持的校验规则 inclusion
  end

end
