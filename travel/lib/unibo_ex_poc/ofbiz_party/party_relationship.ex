defmodule UniboExPoc.Ofbiz.Party.PartyRelationship do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_relationships"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_party_relationship

    queries do
      get :get_party_party_relationship, :read
      list :list_party_party_relationships, :read
    end

    mutations do
      create :create_party_party_relationship, :create
      update :update_party_party_relationship, :update
      destroy :delete_party_party_relationship, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
      description "来源日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :relationship_name, :string do
      public? true
      description "关系的正式名称，如公司中的职位头衔"
    end
    attribute :permissions_enum_id, :string do
      public? true
      description "权限枚举编号"
    end
    attribute :position_title, :string do
      public? true
      description "公司内部使用的确切职位名称"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :to_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :from_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_from
    end
    belongs_to :to_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_to
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.Party.StatusItem do
      public? true
      source_attribute :status_id
    end
    belongs_to :priority_type, UniboExPoc.Ofbiz.Party.PriorityType do
      public? true
    end
    belongs_to :party_relationship_type, UniboExPoc.Ofbiz.Party.PartyRelationshipType do
      public? true
    end
    belongs_to :security_group, UniboExPoc.Ofbiz.Party.SecurityGroup do
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
