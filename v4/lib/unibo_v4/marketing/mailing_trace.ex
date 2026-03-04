# Workflow: mailing_trace_flow — 邮件追踪记录流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.MailingTrace do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_mailing_traces"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      constraints one_of: [:outgoing, :sent, :open, :reply, :bounce, :error, :cancel]
      default :outgoing
      public? true
    end
    attribute :sent_datetime, :utc_datetime, public?: true
    attribute :open_datetime, :utc_datetime, public?: true
    attribute :links_click_datetime, :utc_datetime, public?: true
    attribute :reply_datetime, :utc_datetime, public?: true
    attribute :failure_type, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mailing, UniboV4.Marketing.Mailing do
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
      accept [:status, :sent_datetime, :open_datetime, :links_click_datetime, :reply_datetime, :failure_type]
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
