defmodule UniboV4.Accounting.PaymentApplication do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "payment_applications"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_application

    queries do
      get :get_payment_application, :read
      list :list_payment_applications, :read
    end

    mutations do
      create :create_payment_application, :create
      destroy :delete_payment_application, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :applied_amount, :decimal, allow_nil?: false
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :payment, UniboV4.Accounting.Payment do
      allow_nil? false
    end
    belongs_to :invoice, UniboV4.Accounting.Invoice do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:applied_amount, :notes]
      argument :payment_id, :uuid, allow_nil?: false
      argument :invoice_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      change manage_relationship(:invoice_id, :invoice, type: :append, on_lookup: :relate)
    end
  end

  validations do
    validate compare(:applied_amount, greater_than: 0)
  end

end
