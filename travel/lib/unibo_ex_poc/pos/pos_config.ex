# Workflow: config_management — POS 终端配置管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.POS.PosConfig do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "POS 终端配置，包含基础设置及餐饮模式相关开关"
  end

  postgres do
    table "pos_configs"
    repo UniboExPoc.Repo
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
      description "终端名称"
    end
    attribute :module_pos_restaurant, :boolean do
      default false
      public? true
      description "是否启用餐饮模式"
    end
    attribute :iface_splitbill, :boolean do
      default false
      public? true
      description "启用分单功能（餐饮模式）"
    end
    attribute :iface_printbill, :boolean do
      default false
      public? true
      description "启用账单打印（餐饮模式）"
    end
    attribute :iface_orderline_notes, :boolean do
      default false
      public? true
      description "启用订单行备注（餐饮模式）"
    end
    attribute :set_tip_after_payment, :boolean do
      default false
      public? true
      description "支付后设置小费"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :sessions, UniboExPoc.POS.PosSession do
      public? true
      destination_attribute :config_id
    end
    has_many :floor_links, UniboExPoc.POS.PosConfigFloor do
      public? true
      destination_attribute :config_id
    end
    many_to_many :floors, UniboExPoc.POS.RestaurantFloor do
      public? true
      through UniboExPoc.POS.PosConfigFloor
      source_attribute_on_join_resource :config_id
      destination_attribute_on_join_resource :floor_id
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
    validate present(:)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
