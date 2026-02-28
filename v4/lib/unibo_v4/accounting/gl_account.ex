defmodule UniboV4.Accounting.GlAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "gl_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :gl_account

    queries do
      get :get_gl_account, :read
      list :list_gl_accounts, :read
    end

    mutations do
      create :create_gl_account, :create
      update :update_gl_account, :update
      update :deactivate_gl_account, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :account_code, :string, allow_nil?: false
    attribute :account_name, :string, allow_nil?: false
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:asset, :liability, :equity, :revenue, :expense]
    end
    attribute :parent_account_code, :string
    attribute :description, :string
    attribute :is_active, :boolean, default: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:account_code, :account_name, :account_type, :parent_account_code, :description]
      validate present(:account_code)
      validate present(:account_name)
    end
    update :update do
      primary? true
      accept [:account_name, :description, :is_active, :parent_account_code]
    end
    update :deactivate do
      accept []
      validate attribute_equals(:is_active, true) do
        message "只有活跃科目可以停用"
      end
      change set_attribute(:is_active, :false)
    end
  end

  identities do
    identity :unique_account_code, [:account_code]
  end

end
