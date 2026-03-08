defmodule UniboExPoc.Ofbiz.Party.Agreement do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreements"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement

    queries do
      get :get_party_agreement, :read
      list :list_party_agreements, :read
    end

    mutations do
      create :create_party_agreement, :create
      update :update_party_agreement, :update
      destroy :delete_party_agreement, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :agreement_id, :string do
      public? true
      description "协议编号"
    end
    attribute :agreement_date, :utc_datetime do
      public? true
      description "协议日期"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "来源日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :text_data, :string do
      public? true
      description "长文本数据"
    end
    attribute :status_id, :string do
      public? true
      description "状态编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Party.Product do
      public? true
    end
    belongs_to :from_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :from_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_from
    end
    belongs_to :to_party, UniboExPoc.Ofbiz.Party.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :to_role_type, UniboExPoc.Ofbiz.Party.RoleType do
      public? true
      source_attribute :role_type_id_to
    end
    belongs_to :agreement_type, UniboExPoc.Ofbiz.Party.AgreementType do
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
