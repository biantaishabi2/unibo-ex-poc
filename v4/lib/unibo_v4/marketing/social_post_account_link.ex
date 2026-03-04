defmodule UniboV4.Marketing.SocialPostAccountLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_social_post_account_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
