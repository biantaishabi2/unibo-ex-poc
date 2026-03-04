defmodule UniboV4.Purchasing.AccountMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_account_moves"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :purchase_order, UniboV4.Purchasing.PurchaseOrder do
      public? true
    end
  end

  actions do
    defaults [:read]
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
  end

end
