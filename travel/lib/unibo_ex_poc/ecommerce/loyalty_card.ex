# Workflow: card_lifecycle — 积分卡生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> add_points
#   create --> share
#   add_points --> add_points
#   add_points --> update
#   add_points --> share
#   update --> update
#   update --> add_points
#   update --> share
#   share --> add_points
#   share --> update
# ```
defmodule UniboExPoc.Ecommerce.LoyaltyCard do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "积分卡/优惠券实例（发放给客户）"
  end

  postgres do
    table "ecommerce_loyalty_cards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_loyalty_card

    queries do
      get :get_ecommerce_loyalty_card, :read
      list :list_ecommerce_loyalty_cards, :read
    end

    mutations do
      create :create_ecommerce_loyalty_card, :create
      update :update_ecommerce_loyalty_card, :update
      update :add_points_ecommerce_loyalty_card, :add_points
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      public? true
      description "卡号/优惠码"
    end
    attribute :points, :decimal do
      default 0
      public? true
      description "当前积分余额"
    end
    attribute :expiration_date, :date do
      public? true
      description "过期日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboExPoc.Ecommerce.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.Ecommerce.Party do
      public? true
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:code, :points, :expiration_date]
      argument :program_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:points, :expiration_date]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :add_points do
      description "为积分卡增加积分"
      accept [:points]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :share do
      description "生成优惠券分享链接"
      argument :card_id, :uuid, allow_nil?: false
      run fn input, _context ->
        :ok
      end
    end
  end

  validations do
    validate compare(:points, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_loyalty_card_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
