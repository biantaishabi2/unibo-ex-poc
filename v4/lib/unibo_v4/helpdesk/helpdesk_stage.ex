defmodule UniboV4.Helpdesk.HelpdeskStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_stages"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :sequence, :integer, public?: true
  end

  actions do
    defaults [:read]
  end

end
