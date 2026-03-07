defmodule UniboExPoc.Ofbiz.Product.ProductMaint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "用于指定定期维护的详细信息"
  end

  postgres do
    table "product_maints"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_maint

    queries do
      get :get_product_product_maint, :read
      list :list_product_product_maints, :read
    end

    mutations do
      create :create_product_product_maint, :create
      update :update_product_product_maint, :update
      destroy :delete_product_product_maint, :destroy
    end

  end

  attributes do
    attribute :product_maint_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :maint_name, :string, public?: true
    attribute :maint_template_work_effort_id, :string do
      public? true
      description "维护计划模板。WorkEffort可能具有任务/故障细节的WorkEffortAssocs"
    end
    attribute :interval_quantity, :decimal, public?: true
    attribute :interval_uom_id, :string do
      public? true
      description "intervalQuantity的计量单位；如果使用此项，通常不使用intervalMeterTypeId（二者之一）"
    end
    attribute :repeat_count, :integer do
      public? true
      description "若为0或空表示无重复限制；可用于单个ProductMaintType的多个ProductMaint记录，以处理维护间隔不均匀分布或仅需执行一次（如磨合期）的情况"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
    end
    belongs_to :product_maint_type, UniboExPoc.Ofbiz.Product.ProductMaintType do
      public? true
    end
    belongs_to :interval_product_meter_type, UniboExPoc.Ofbiz.Product.ProductMeterType do
      public? true
      source_attribute :interval_meter_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
