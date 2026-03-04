defmodule UniboV4.Communication.ResPartner do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "communication_res_partners"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  relationships do
    has_many :mail_group_memberships, UniboV4.Communication.MailGroupMember do
      public? true
      destination_attribute :partner_id
    end
  end

  actions do
    defaults [:read]
  end

end
