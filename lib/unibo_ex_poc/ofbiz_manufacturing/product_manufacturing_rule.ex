defmodule UniboV4.Ofbiz.Manufacturing.ProductManufacturingRule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "manufacturing_product_manufacturing_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_product_manufacturing_rule

    queries do
      get :get_manufacturing_product_manufacturing_rule, :read
      list :list_manufacturing_product_manufacturing_rules, :read
    end

    mutations do
      create :create_manufacturing_product_manufacturing_rule, :create
      update :update_manufacturing_product_manufacturing_rule, :update
      destroy :delete_manufacturing_product_manufacturing_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :rule_id, :string do
      public? true
      description "规则编号"
    end
    attribute :product_id, :string do
      public? true
      description "产品编号"
    end
    attribute :product_id_for, :string do
      public? true
      description "用于产品编号"
    end
    attribute :product_id_in, :string do
      public? true
      description "产品编号包含"
    end
    attribute :rule_seq_id, :string do
      public? true
      description "规则序列编号"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "来源日期"
    end
    attribute :product_id_in_subst, :string do
      public? true
      description "替代产品编号"
    end
    attribute :product_feature, :string do
      public? true
      description "产品功能"
    end
    attribute :rule_operator, :string do
      public? true
      description "规则操作员"
    end
    attribute :quantity, :float do
      public? true
      description "数量"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "到日期"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
