defmodule UniboExPoc.PurchasingV3.Party do
  @moduledoc """
  V3 供应商主体：增加风险维度用于下单前拦截。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.PurchasingV3,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:party_v3)

    queries do
      get(:get_party_v3, :read)
      list(:list_parties_v3, :read)
    end

    mutations do
      create(:create_party_v3, :create)
      update(:update_party_v3, :update)
    end
  end

  postgres do
    table("v3_parties")
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

    attribute :risk_level, :atom do
      constraints(one_of: [:low, :medium, :high])
      default(:low)
      allow_nil?(false)
      public?(true)
    end

    attribute :is_blocked, :boolean do
      default(false)
      allow_nil?(false)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :status, :risk_level, :is_blocked])
    end

    update :update do
      accept([:name, :status, :risk_level, :is_blocked])
    end
  end
end
