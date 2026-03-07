defmodule UniboExPoc.Ofbiz.Product.OldProductPromoCodeEmail do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "自分支版本起已弃用：即将推出的分支。请改用ProdPromoCodeContactMech"
  end

  postgres do
    table "product_old_product_promo_code_emails"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_old_product_promo_code_email

    queries do
      get :get_product_old_product_promo_code_email, :read
      list :list_product_old_product_promo_code_emails, :read
    end

    mutations do
      create :create_product_old_product_promo_code_email, :create
      update :update_product_old_product_promo_code_email, :update
      destroy :delete_product_old_product_promo_code_email, :destroy
    end

  end

  attributes do
    attribute :product_promo_code_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :email_address, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_promo_code, UniboExPoc.Ofbiz.Product.ProductPromoCode do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
