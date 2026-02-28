defmodule UniboExPoc.Purchasing.Party do
  @moduledoc """
  参与方 — 对应 OFBiz Party + PartyGroup/Person。
  采购场景中扮演供应商（SUPPLIER）或买方（BUYER）角色。
  """
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type(:party)

    queries do
      get(:get_party, :read)
      list(:list_parties, :read)
    end

    mutations do
      create :create_party, :create
      update(:update_party, :update)
    end
  end

  postgres do
    table("parties")
    repo(UniboExPoc.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    # 对应 OFBiz Party.partyTypeId — 简化为枚举
    attribute :party_type, :atom do
      constraints(one_of: [:person, :party_group])
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz Party.externalId
    attribute :external_id, :string do
      public?(true)
    end

    # 对应 OFBiz PartyGroup.groupName / Person.firstName+lastName
    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz Party.description
    attribute :description, :string do
      public?(true)
    end

    # 对应 OFBiz Party.statusId
    attribute :status, :atom do
      constraints(one_of: [:active, :inactive])
      default(:active)
      public?(true)
    end

    # 对应 OFBiz PartyRole.roleTypeId — 采购场景核心角色
    attribute :role, :atom do
      constraints(one_of: [:supplier, :buyer, :carrier, :bill_to])
      allow_nil?(false)
      public?(true)
    end

    # 对应 OFBiz Party.preferredCurrencyUomId
    attribute :preferred_currency, :string do
      default("CNY")
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:party_type, :external_id, :name, :description, :status, :role, :preferred_currency])
    end

    update :update do
      accept([:name, :description, :status, :preferred_currency])
    end
  end

  identities do
    # 外部系统ID唯一
    identity(:external_id, [:external_id], pre_check?: true)
  end
end
