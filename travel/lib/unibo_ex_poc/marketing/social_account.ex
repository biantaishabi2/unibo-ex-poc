# Workflow: social_account_lifecycle — 社交账户生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> connect
#   connect --> disconnect
#   connect --> refresh_token
#   disconnect --> [*]
#   refresh_token --> disconnect
#   refresh_token --> refresh_token
# ```
defmodule UniboExPoc.Marketing.SocialAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "社交媒体平台账户"
  end

  postgres do
    table "marketing_social_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_social_account

    queries do
      get :get_marketing_social_account, :read
      list :list_marketing_social_accounts, :read
    end

    mutations do
      create :create_marketing_social_account, :create
      update :connect_marketing_social_account, :connect
      update :disconnect_marketing_social_account, :disconnect
      update :refresh_token_marketing_social_account, :refresh_token
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "账户显示名称"
    end
    attribute :platform, :atom do
      allow_nil? false
      constraints one_of: [:facebook, :instagram, :linkedin, :twitter, :youtube]
      public? true
      description "平台类型"
    end
    attribute :platform_account_id, :string do
      allow_nil? false
      public? true
      description "平台侧账户 ID"
    end
    attribute :access_token, :string do
      public? true
      description "OAuth 访问令牌（加密存储）"
    end
    attribute :refresh_token, :string do
      public? true
      description "OAuth 刷新令牌（加密存储）"
    end
    attribute :token_expires_at, :utc_datetime do
      public? true
      description "令牌过期时间"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :avatar_url, :string do
      public? true
      description "账户头像 URL"
    end
    attribute :profile_url, :string do
      public? true
      description "账户主页 URL"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :company, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :platform, :platform_account_id]
      validate present(:name)
      validate present(:platform)
      change set_attribute(:id, expr(id))
    end
    update :connect do
      description "OAuth 授权连接"
      primary? true
      accept []
      # skipped: validate unique : (incompatible with bulk update atomic path)
      change UniboExPoc.Marketing.Changes.SocialAccount.ConnectCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :disconnect do
      description "断开连接"
      accept []
      change set_attribute(:is_active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :refresh_token do
      description "刷新 OAuth 令牌"
      accept []
      # skipped: validate present : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用的账户可以刷新令牌"
      change UniboExPoc.Marketing.Changes.SocialAccount.RefreshTokenCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_platform_account_id, [:platform, :platform_account_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
