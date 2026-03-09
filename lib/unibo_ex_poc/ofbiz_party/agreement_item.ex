defmodule UniboExPoc.Ofbiz.Party.AgreementItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_item

    queries do
      get :get_party_agreement_item, :read
      list :list_party_agreement_items, :read
    end

    mutations do
      create :create_party_agreement_item, :create
      update :update_party_agreement_item, :update
      destroy :delete_party_agreement_item, :destroy
    end

  end

  attributes do
    attribute :agreement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "协议项序列编号"
    end
    attribute :currency_uom_id, :string do
      public? true
      description "货币单位编号"
    end
    attribute :agreement_text, :string do
      public? true
      description "协议长文本"
    end
    attribute :agreement_image, :string do
      public? true
      description "协议图片"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :agreement_item_type, UniboExPoc.Ofbiz.Party.AgreementItemType do
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
