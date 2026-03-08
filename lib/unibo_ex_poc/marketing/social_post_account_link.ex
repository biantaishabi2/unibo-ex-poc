defmodule UniboV4.Marketing.SocialPostAccountLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "社交帖子-社交账号桥接占位实体"
  end

  postgres do
    table "marketing_social_post_account_links"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_social_post_account_link

    queries do
      get :get_marketing_social_post_account_link, :read
      list :list_marketing_social_post_account_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :social_post, UniboV4.Marketing.SocialPost do
      public? true
      allow_nil? false
    end
    belongs_to :social_account, UniboV4.Marketing.SocialAccount do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
