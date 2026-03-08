defmodule UniboV4.Ofbiz.Party.FtpAddress do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_ftp_addresses"
    repo UniboV4.Repo
  end

  graphql do
    type :party_ftp_address

    queries do
      get :get_party_ftp_address, :read
      list :list_party_ftp_addresss, :read
    end

    mutations do
      create :create_party_ftp_address, :create
      update :update_party_ftp_address, :update
      destroy :delete_party_ftp_address, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :hostname, :string do
      public? true
      description "主机名"
    end
    attribute :port, :integer do
      public? true
      description "端口"
    end
    attribute :username, :string do
      public? true
      description "用户名"
    end
    attribute :ftp_password, :string do
      public? true
      description "FTP密码"
    end
    attribute :binary_transfer, :boolean do
      public? true
      description "二进制转账"
    end
    attribute :file_path, :string do
      public? true
      description "文件路径"
    end
    attribute :zip_file, :boolean do
      public? true
      description "邮编文件"
    end
    attribute :passive_mode, :boolean do
      public? true
      description "被动模式"
    end
    attribute :default_timeout, :integer do
      public? true
      description "默认超时"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :contact_mech, UniboV4.Ofbiz.Party.ContactMech do
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
