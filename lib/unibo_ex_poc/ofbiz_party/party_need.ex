defmodule UniboV4.Ofbiz.Party.PartyNeed do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_needs"
    repo UniboV4.Repo
  end

  graphql do
    type :party_party_need

    queries do
      get :get_party_party_need, :read
      list :list_party_party_needs, :read
    end

    mutations do
      create :create_party_party_need, :create
      update :update_party_party_need, :update
      destroy :delete_party_party_need, :destroy
    end

  end

  attributes do
    attribute :party_need_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "参与方需求编号"
    end
    attribute :visit_id, :string do
      public? true
      description "访问编号"
    end
    attribute :datetime_recorded, :utc_datetime do
      public? true
      description "记录日期时间"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :need_type, UniboV4.Ofbiz.Party.NeedType do
      public? true
    end
    belongs_to :party, UniboV4.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :role_type, UniboV4.Ofbiz.Party.RoleType do
      public? true
    end
    belongs_to :party_type, UniboV4.Ofbiz.Party.PartyType do
      public? true
    end
    belongs_to :communication_event, UniboV4.Ofbiz.Party.CommunicationEvent do
      public? true
    end
    belongs_to :product, UniboV4.Ofbiz.Party.Product do
      public? true
    end
    belongs_to :product_category, UniboV4.Ofbiz.Party.ProductCategory do
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
