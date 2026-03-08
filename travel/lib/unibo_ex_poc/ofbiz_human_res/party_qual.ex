defmodule UniboExPoc.Ofbiz.HumanRes.PartyQual do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_party_quals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_party_qual

    queries do
      get :get_human_res_party_qual, :read
      list :list_human_res_party_quals, :read
    end

    mutations do
      create :create_human_res_party_qual, :create
      update :update_human_res_party_qual, :update
      destroy :delete_human_res_party_qual, :destroy
    end

  end

  attributes do
    attribute :qualification_desc, :string, public?: true
    attribute :title, :string do
      public? true
      description "学位或职位名称"
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :party_qual_type, UniboExPoc.Ofbiz.HumanRes.PartyQualType do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :verification_status_item, UniboExPoc.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :verif_status_id
      attribute_type :string
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
