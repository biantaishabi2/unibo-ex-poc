# Workflow: config_management — POS 终端配置管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.POS.PosConfig do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pos_configs"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_pos_config

    queries do
      get :get_pos_pos_config, :read
      list :list_pos_pos_configs, :read
    end

    mutations do
      create :create_pos_pos_config, :create
      update :update_pos_pos_config, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :module_pos_restaurant, :boolean do
      default false
      public? true
    end
    attribute :iface_splitbill, :boolean do
      default false
      public? true
    end
    attribute :iface_printbill, :boolean do
      default false
      public? true
    end
    attribute :iface_orderline_notes, :boolean do
      default false
      public? true
    end
    attribute :set_tip_after_payment, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :sessions, UniboV4.POS.PosSession do
      public? true
      destination_attribute :config_id
    end
    has_many :floor_links, UniboV4.POS.PosConfigFloor do
      public? true
      destination_attribute :config_id
    end
    many_to_many :floors, UniboV4.POS.RestaurantFloor do
      public? true
      through UniboV4.POS.PosConfigFloor
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :module_pos_restaurant, :iface_splitbill, :iface_printbill, :iface_orderline_notes, :set_tip_after_payment]
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
      accept [:name, :module_pos_restaurant, :iface_splitbill, :iface_printbill, :iface_orderline_notes, :set_tip_after_payment]
      change set_attribute(:iface_splitbill, false)
      change set_attribute(:iface_printbill, false)
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
    # TODO: 不支持的校验规则 custom
  end

end
