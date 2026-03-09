defmodule UniboExPoc.Ofbiz.Party.TelecomNumber do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_telecom_numbers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_telecom_number

    queries do
      get :get_party_telecom_number, :read
      list :list_party_telecom_numbers, :read
    end

    mutations do
      create :create_party_telecom_number, :create
      update :update_party_telecom_number, :update
      destroy :delete_party_telecom_number, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :country_code, :string do
      public? true
      description "国家编码"
    end
    attribute :area_code, :string do
      public? true
      description "地区编码"
    end
    attribute :contact_number, :string do
      public? true
      description "联系单号"
    end
    attribute :ask_for_name, :string do
      public? true
      description "提问名称"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech, UniboExPoc.Ofbiz.Party.ContactMech do
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
