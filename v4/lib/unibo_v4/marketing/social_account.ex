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
defmodule UniboV4.Marketing.SocialAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "marketing_social_accounts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :platform, :atom do
      allow_nil? false
      constraints one_of: [:facebook, :instagram, :linkedin, :twitter, :youtube]
      public? true
    end
    attribute :platform_account_id, :string do
      allow_nil? false
      public? true
    end
    attribute :access_token, :string, public?: true
    attribute :refresh_token, :string, public?: true
    attribute :token_expires_at, :utc_datetime, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :avatar_url, :string, public?: true
    attribute :profile_url, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :company, UniboV4.Marketing.Company do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :platform, :platform_account_id]
      validate present(:name)
      validate present(:platform)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :connect do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :disconnect do
      accept []
      change set_attribute(:is_active, false)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :refresh_token do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用的账户可以刷新令牌"
      # TODO: 不支持的 change effect custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_platform_account_id, [:platform, :platform_account_id]
  end

end
