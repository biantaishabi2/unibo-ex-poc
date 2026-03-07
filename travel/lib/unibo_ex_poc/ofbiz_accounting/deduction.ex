defmodule UniboExPoc.Ofbiz.Accounting.Deduction do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_deductions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_deduction

    queries do
      get :get_accounting_deduction, :read
      list :list_accounting_deductions, :read
    end

    mutations do
      create :create_accounting_deduction, :create
      update :update_accounting_deduction, :update
      destroy :delete_accounting_deduction, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :deduction_id, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :deduction_type, UniboExPoc.Ofbiz.Accounting.DeductionType do
      public? true
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
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
