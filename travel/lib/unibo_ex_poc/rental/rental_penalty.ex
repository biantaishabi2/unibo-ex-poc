# Workflow: rental_penalty_maintain_flow — 逾期罚金配置维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Rental.RentalPenalty do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "逾期罚金配置（支持产品级和全局默认，含宽限期和封顶机制）"
  end

  postgres do
    table "rental_penalties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rental_rental_penalty

    queries do
      get :get_rental_rental_penalty, :read
      list :list_rental_rental_penaltys, :read
    end

    mutations do
      create :create_rental_rental_penalty, :create
      update :update_rental_rental_penalty, :update
      destroy :delete_rental_rental_penalty, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_tmpl_id, :uuid do
      public? true
      description "关联产品模板（null 则为全局默认配置）"
    end
    attribute :extra_hour_cost, :decimal do
      allow_nil? false
      public? true
      description "每小时逾期费用"
    end
    attribute :extra_day_cost, :decimal do
      allow_nil? false
      public? true
      description "每天逾期费用"
    end
    attribute :grace_period_hours, :float do
      allow_nil? false
      public? true
      description "宽限期（小时），宽限期内不计罚金"
    end
    attribute :max_penalty_pct, :float do
      default 0
      public? true
      description "罚金上限比例（占租赁总价 %，0 表示无上限）"
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
      description "币种"
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
      description "所属公司"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_template, UniboExPoc.Rental.ProductTemplate do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:product_tmpl_id, :extra_hour_cost, :extra_day_cost, :grace_period_hours, :max_penalty_pct, :currency_id, :company_id]
    end
    update :update do
      primary? true
      accept [:extra_hour_cost, :extra_day_cost, :grace_period_hours, :max_penalty_pct]
      require_atomic? false
    end
  end

  validations do
    validate compare(:extra_hour_cost, greater_than_or_equal_to: 0)
    validate compare(:extra_day_cost, greater_than_or_equal_to: 0)
    validate compare(:grace_period_hours, greater_than_or_equal_to: 0)
    validate compare(:max_penalty_pct, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
