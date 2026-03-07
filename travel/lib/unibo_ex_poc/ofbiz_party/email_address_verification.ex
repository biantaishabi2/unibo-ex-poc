defmodule UniboExPoc.Ofbiz.Party.EmailAddressVerification do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "存储邮箱地址验证的哈希值"
  end

  postgres do
    table "party_email_address_verifications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_email_address_verification

    queries do
      get :get_party_email_address_verification, :read
      list :list_party_email_address_verifications, :read
    end

    mutations do
      create :create_party_email_address_verification, :create
      update :update_party_email_address_verification, :update
      destroy :delete_party_email_address_verification, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email_address, :string do
      public? true
      description "邮箱地址"
    end
    attribute :verify_hash, :string do
      public? true
      description "核实哈希"
    end
    attribute :expire_date, :utc_datetime do
      public? true
      description "过期日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
