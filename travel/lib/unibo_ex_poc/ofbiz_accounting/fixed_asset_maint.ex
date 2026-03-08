defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetMaint do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_maints"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_maint

    queries do
      get :get_accounting_fixed_asset_maint, :read
      list :list_accounting_fixed_asset_maints, :read
    end

    mutations do
      create :create_accounting_fixed_asset_maint, :create
      update :update_accounting_fixed_asset_maint, :update
      destroy :delete_accounting_fixed_asset_maint, :destroy
    end

  end

  attributes do
    attribute :maint_hist_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :status_id, :string, public?: true
    attribute :product_maint_type_id, :string do
      public? true
      description "如果已知产品维护序列号，可以使用该值和固定资产产品编号进行查找；对于非计划维护，直接填充"
    end
    attribute :product_maint_seq_id, :string do
      public? true
      description "可选，但应填充以便确定所有计划维护中即将到来的维护任务"
    end
    attribute :schedule_work_effort_id, :string do
      public? true
      description "具有预计/实际开始和完成日期等字段"
    end
    attribute :interval_quantity, :decimal, public?: true
    attribute :interval_uom_id, :string do
      public? true
      description "间隔数量的单位；与间隔计量类型二选一；如果也进行了与间隔无关的表读数，应在固定资产计量记录中跟踪"
    end
    attribute :interval_meter_type_id, :string do
      public? true
      description "间隔数量的计量类型；与间隔单位二选一"
    end
    attribute :purchase_order_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
    end
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
