defmodule UniboExPoc.Ofbiz.Product.ProductCategoryLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_category_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_category_link

    queries do
      get :get_product_product_category_link, :read
      list :list_product_product_category_links, :read
    end

    mutations do
      create :create_product_product_category_link, :create
      update :update_product_product_category_link, :update
      destroy :delete_product_product_category_link, :destroy
    end

  end

  attributes do
    attribute :link_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string do
      public? true
      description "内部评论，不用于公开显示"
    end
    attribute :sequence_num, :integer do
      public? true
      description "此字段用于排序链接。linkSeqId字段不被使用，因为它是主键的一部分，无法更改"
    end
    attribute :title_text, :string, public?: true
    attribute :detail_text, :string, public?: true
    attribute :image_url, :string, public?: true
    attribute :image_two_url, :string, public?: true
    attribute :link_type_enum_id, :string, public?: true
    attribute :link_info, :string, public?: true
    attribute :detail_sub_screen, :string do
      public? true
      description "此字段为可选。如果未指定，类别详情模板应使用默认值"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_category, UniboExPoc.Ofbiz.Product.ProductCategory do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
