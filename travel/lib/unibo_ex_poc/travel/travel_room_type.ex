defmodule UniboExPoc.Travel.TravelRoomType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "酒店房型主数据（Travel 层，来源 OFBiz ProductFeature）"
  end

  postgres do
    table "travel_room_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :travel_travel_room_type

    queries do
      get :get_travel_travel_room_type, :read
      list :list_travel_travel_room_types, :read
    end

    mutations do
      create :create_travel_travel_room_type, :create
      update :update_travel_travel_room_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :room_type_code, :string do
      allow_nil? false
      public? true
      description "房型规范编码"
    end
    attribute :room_type_name, :string do
      allow_nil? false
      public? true
      description "房型名称"
    end
    attribute :hotel_code, :string do
      public? true
      description "酒店编码冗余（便于兼容检索）"
    end
    attribute :bed_type, :string do
      public? true
      description "床型"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
  end

  relationships do
    belongs_to :hotel, UniboExPoc.Travel.TravelHotel do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:room_type_code, :room_type_name, :hotel_code, :bed_type, :status]
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
      accept [:room_type_name, :hotel_code, :bed_type, :status]
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
    identity :unique_room_type_code, [:room_type_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
