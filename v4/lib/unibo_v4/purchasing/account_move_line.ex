defmodule UniboV4.Purchasing.AccountMoveLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_account_move_lines"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :move, UniboV4.Purchasing.AccountMove do
      public? true
      source_attribute :account_move_id
    end
    belongs_to :purchase_line, UniboV4.Purchasing.PurchaseOrderLine do
      public? true
      source_attribute :purchase_order_line_id
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
