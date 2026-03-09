defmodule UniboExPoc.Organization.PartyRelationship do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "主体间关系，支持汇报、隶属、管理、子公司等关系类型，带有效期"
  end

  postgres do
    table "organization_party_relationships"
    repo UniboExPoc.Repo
  end

  graphql do
    type :organization_party_relationship

    queries do
      get :get_organization_party_relationship, :read
      list :list_organization_party_relationships, :read
    end

    mutations do
      create :create_organization_party_relationship, :create
      update :update_organization_party_relationship, :update
      destroy :delete_organization_party_relationship, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :relationship_type, :atom do
      allow_nil? false
      constraints one_of: [:reports_to, :belongs_to_org, :manages, :subsidiary_of]
      public? true
      description "关系类型"
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      public? true
      description "关系起始时间"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "关系结束时间（空表示当前有效）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
    belongs_to :to_party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:relationship_type, :from_date, :thru_date]
      argument :from_party_id, :uuid, allow_nil?: false
      argument :to_party_id, :uuid, allow_nil?: false
      change manage_relationship(:from_party_id, :from_party, type: :append, on_lookup: :relate)
      change manage_relationship(:to_party_id, :to_party, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:relationship_type, :from_date, :thru_date]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    # WARNING: compare :from_party_id 参数无法识别，请检查 YAML 定义
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
