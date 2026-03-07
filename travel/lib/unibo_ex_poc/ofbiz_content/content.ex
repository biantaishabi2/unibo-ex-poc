defmodule UniboExPoc.Ofbiz.Content.Content do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_content

    queries do
      get :get_content_content, :read
      list :list_content_contents, :read
    end

    mutations do
      create :create_content_content, :create
      update :update_content_content, :update
      destroy :delete_content_content, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :content_id, :string, public?: true
    attribute :data_source_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :privilege_enum_id, :string, public?: true
    attribute :service_name, :string do
      public? true
      description "已弃用：改用 customMethod 模式。保持向后兼容"
    end
    attribute :custom_method_id, :string, public?: true
    attribute :content_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :locale_string, :string, public?: true
    attribute :child_leaf_count, :integer, public?: true
    attribute :child_branch_count, :integer, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :content_type, UniboExPoc.Ofbiz.Content.ContentType do
      public? true
      attribute_type :string
    end
    belongs_to :data_resource, UniboExPoc.Ofbiz.Content.DataResource do
      public? true
      attribute_type :string
    end
    belongs_to :template_data_resource, UniboExPoc.Ofbiz.Content.DataResource do
      public? true
      attribute_type :string
    end
    belongs_to :mime_type, UniboExPoc.Ofbiz.Content.MimeType do
      public? true
      attribute_type :string
    end
    belongs_to :character_set, UniboExPoc.Ofbiz.Content.CharacterSet do
      public? true
      attribute_type :string
    end
    belongs_to :decorator_content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
    end
    belongs_to :owner_content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
    end
    belongs_to :instance_of_content, UniboExPoc.Ofbiz.Content.Content do
      public? true
      attribute_type :string
    end
    has_many :content_assoc_data_resource_view_from, UniboExPoc.Ofbiz.Content.ContentAssoc do
      public? true
      source_attribute :content_id
      destination_attribute :content_id
    end
    has_many :content_assocs_to, UniboExPoc.Ofbiz.Content.ContentAssoc do
      public? true
      destination_attribute :content_id_to
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
    archive_related [:content_assoc_data_resource_view_from, :content_assocs_to]
  end

end
