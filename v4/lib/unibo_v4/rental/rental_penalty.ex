# Workflow: rental_penalty_maintain_flow — 逾期罚金配置维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Rental.RentalPenalty do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rental_penalties"
    repo UniboV4.Repo
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
    attribute :product_tmpl_id, :uuid, public?: true
    attribute :extra_hour_cost, :decimal do
      allow_nil? false
      public? true
    end
    attribute :extra_day_cost, :decimal do
      allow_nil? false
      public? true
    end
    attribute :grace_period_hours, :float do
      allow_nil? false
      public? true
    end
    attribute :max_penalty_pct, :float do
      default 0
      public? true
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :product_template, UniboV4.Rental.ProductTemplate do
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
    end
  end

  validations do
    validate compare(:extra_hour_cost, greater_than_or_equal_to: 0)
    validate compare(:extra_day_cost, greater_than_or_equal_to: 0)
    validate compare(:grace_period_hours, greater_than_or_equal_to: 0)
    validate compare(:max_penalty_pct, greater_than_or_equal_to: 0)
  end

end
