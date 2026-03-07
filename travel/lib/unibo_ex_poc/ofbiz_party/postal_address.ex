defmodule UniboExPoc.Ofbiz.Party.PostalAddress do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_postal_addresses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_postal_address

    queries do
      get :get_party_postal_address, :read
      list :list_party_postal_addresss, :read
    end

    mutations do
      create :create_party_postal_address, :create
      update :update_party_postal_address, :update
      destroy :delete_party_postal_address, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :to_name, :string do
      public? true
      description "收件人姓名"
    end
    attribute :attn_name, :string do
      public? true
      description "收件人名称"
    end
    attribute :address1, :string do
      public? true
      description "地址1"
    end
    attribute :address2, :string do
      public? true
      description "地址2"
    end
    attribute :house_number, :integer do
      public? true
      description "房号"
    end
    attribute :house_number_ext, :string do
      public? true
      description "房号扩展"
    end
    attribute :directions, :string do
      public? true
      description "方向"
    end
    attribute :city, :string do
      public? true
      description "城市"
    end
    attribute :postal_code, :string do
      public? true
      description "邮政编码"
    end
    attribute :postal_code_ext, :string do
      public? true
      description "邮政编码扩展"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
      public? true
    end
    belongs_to :country_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :state_province_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :county_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :municipality_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :city_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :postal_code_geo, UniboExPoc.Ofbiz.Party.Geo do
      public? true
    end
    belongs_to :geo_point, UniboExPoc.Ofbiz.Party.GeoPoint do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
