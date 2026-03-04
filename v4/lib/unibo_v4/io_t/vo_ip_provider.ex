# Workflow: voip_provider_lifecycle_flow — VoIP 服务商配置创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.IoT.VoIPProvider do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "io_t_vo_ip_providers"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sip_server, :string do
      allow_nil? false
      public? true
    end
    attribute :sip_port, :integer do
      default 5060
      public? true
    end
    attribute :transport, :atom do
      allow_nil? false
      constraints one_of: [:udp, :tcp, :tls, :wss]
      default :wss
      public? true
    end
    attribute :domain, :string do
      allow_nil? false
      public? true
    end
    attribute :outbound_proxy, :string, public?: true
    attribute :stun_server, :string, public?: true
    attribute :turn_server, :string, public?: true
    attribute :turn_username, :string, public?: true
    attribute :turn_password, :string, public?: true
    attribute :is_default, :boolean do
      default false
      public? true
    end
  end

  relationships do
    belongs_to :org, UniboV4.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :calls, UniboV4.IoT.VoIPCall do
      public? true
      destination_attribute :provider_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sip_server, :sip_port, :transport, :domain, :outbound_proxy, :stun_server, :turn_server, :turn_username, :turn_password, :is_default]
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:sip_server)
      validate present(:domain)
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
      accept [:name, :sip_server, :sip_port, :transport, :domain, :outbound_proxy, :stun_server, :turn_server, :turn_username, :turn_password, :is_default]
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
    identity :unique_default_per_org, [:org_id]
  end

end
