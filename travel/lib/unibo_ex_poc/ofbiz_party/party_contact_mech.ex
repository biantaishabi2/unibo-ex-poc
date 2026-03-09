defmodule UniboExPoc.Ofbiz.Party.PartyContactMech do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_party_contact_meches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_contact_mech

    queries do
      get :get_party_party_contact_mech, :read
      list :list_party_party_contact_mechs, :read
    end

    mutations do
      create :create_party_party_contact_mech, :create
      update :update_party_party_contact_mech, :update
      destroy :delete_party_party_contact_mech, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "来源日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :allow_solicitation, :boolean do
      public? true
      description "允许招揽"
    end
    attribute :extension, :string do
      public? true
      description "扩展"
    end
    attribute :verified, :boolean do
      public? true
      description "已验证"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :years_with_contact_mech, :integer do
      public? true
      description "联系方式使用年数"
    end
    attribute :months_with_contact_mech, :integer do
      public? true
      description "联系方式使用月数"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
    end
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
