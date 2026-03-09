defmodule UniboExPoc.Ofbiz.Party.PartyProfileDefault do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_profile_defaults"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_profile_default

    queries do
      get :get_party_party_profile_default, :read
      list :list_party_party_profile_defaults, :read
    end

    mutations do
      create :create_party_party_profile_default, :create
      update :update_party_party_profile_default, :update
      destroy :delete_party_party_profile_default, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :default_ship_addr, :string do
      public? true
      description "默认收货地址"
    end
    attribute :default_bill_addr, :string do
      public? true
      description "默认账单地址"
    end
    attribute :default_pay_meth, :string do
      public? true
      description "默认支付方式"
    end
    attribute :default_ship_meth, :string do
      public? true
      description "默认发货方式"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :product_store, UniboExPoc.Ofbiz.Party.ProductStore do
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
