defmodule UniboExPoc.Ofbiz.Party.AgreementTerm do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_agreement_terms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_agreement_term

    queries do
      get :get_party_agreement_term, :read
      list :list_party_agreement_terms, :read
    end

    mutations do
      create :create_party_agreement_term, :create
      update :update_party_agreement_term, :update
      destroy :delete_party_agreement_term, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :agreement_term_id, :string do
      public? true
      description "协议条款编号"
    end
    attribute :agreement_item_seq_id, :string do
      public? true
      description "协议项序列编号"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "来源日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :term_value, :decimal do
      public? true
      description "条款值"
    end
    attribute :term_days, :integer do
      public? true
      description "条款天数"
    end
    attribute :text_value, :string do
      public? true
      description "长文本值"
    end
    attribute :min_quantity, :float do
      public? true
      description "最小数量"
    end
    attribute :max_quantity, :float do
      public? true
      description "最大数量"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :term_type, UniboExPoc.Ofbiz.Party.TermType do
      public? true
    end
    belongs_to :agreement, UniboExPoc.Ofbiz.Party.Agreement do
      public? true
    end
    belongs_to :invoice_item_type, UniboExPoc.Ofbiz.Party.InvoiceItemType do
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
