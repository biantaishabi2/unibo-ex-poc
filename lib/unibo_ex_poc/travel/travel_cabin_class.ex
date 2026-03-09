defmodule UniboExPoc.Travel.TravelCabinClass do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "舱位主数据（Travel 层，来源 OFBiz Enumeration）"
  end

  postgres do
    table "travel_cabin_classes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :travel_travel_cabin_class

    queries do
      get :get_travel_travel_cabin_class, :read
      list :list_travel_travel_cabin_classs, :read
    end

    mutations do
      create :create_travel_travel_cabin_class, :create
      update :update_travel_travel_cabin_class, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :cabin_class_code, :string do
      allow_nil? false
      public? true
      description "舱位规范编码"
    end
    attribute :cabin_class_name, :string do
      allow_nil? false
      public? true
      description "舱位名称"
    end
    attribute :cabin_rank, :integer do
      public? true
      description "舱位等级序"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:cabin_class_code, :cabin_class_name, :cabin_rank, :status]
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:cabin_class_name, :cabin_rank, :status]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_cabin_class_code, [:cabin_class_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
