defmodule UniboV4.Communication.Notification do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "communication_notifications"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :notification_status, :string, public?: true
  end

  relationships do
    belongs_to :message, UniboV4.Communication.Message do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
