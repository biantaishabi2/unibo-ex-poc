defmodule UniboV4.IoT.HelpdeskTicket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "io_t_helpdesk_tickets"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read]
  end

end
