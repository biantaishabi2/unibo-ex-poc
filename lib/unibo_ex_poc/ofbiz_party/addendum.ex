defmodule UniboExPoc.Ofbiz.Party.Addendum do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_addendums"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_addendum

    queries do
      get :get_party_addendum, :read
      list :list_party_addendums, :read
    end

    mutations do
      create :create_party_addendum, :create
      update :update_party_addendum, :update
      destroy :delete_party_addendum, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :addendum_id, :string do
      public? true
      description "附录编号"
    end
    attribute :agreement_item_seq_id, :string do
      public? true
      description "协议项序列编号"
    end
    attribute :addendum_creation_date, :utc_datetime do
      public? true
      description "附录创建日期"
    end
    attribute :addendum_effective_date, :utc_datetime do
      public? true
      description "附录生效日期"
    end
    attribute :addendum_text, :string do
      public? true
      description "附录长文本"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
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
