defmodule UniboExPoc.PurchasingV2.Party do
  @moduledoc """
  V2 参与方资源：用于模拟供应商状态和角色信息。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV2,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:party_v2)

    queries do
      get(:get_party_v2, :read)
      list(:list_parties_v2, :read)
    end

    mutations do
      create :create_party_v2, :create
      update(:update_party_v2, :update)
    end
  end

  postgres do
    table("v2_parties")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :status, :atom do
      constraints(one_of: [:active, :inactive])
      default(:active)
      allow_nil?(false)
      public?(true)
    end

    attribute :role, :atom do
      constraints(one_of: [:supplier, :buyer, :admin, :viewer])
      default(:supplier)
      allow_nil?(false)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :status, :role])
    end

    update :update do
      accept([:name, :status, :role])
    end
  end
end
