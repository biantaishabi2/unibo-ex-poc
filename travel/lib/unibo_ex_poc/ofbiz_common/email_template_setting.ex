defmodule UniboExPoc.Ofbiz.Common.EmailTemplateSetting do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Email Template Setting"
  end

  postgres do
    table "common_email_template_settings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :common_email_template_setting

    queries do
      get :get_common_email_template_setting, :read
      list :list_common_email_template_settings, :read
    end

    mutations do
      create :create_common_email_template_setting, :create
      update :update_common_email_template_setting, :update
      destroy :delete_common_email_template_setting, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :email_template_setting_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :body_screen_location, :string do
      public? true
      description "if empty defaults to a screen based on the emailType"
    end
    attribute :xslfo_attach_screen_location, :string do
      public? true
      description "if specified is used to generate XSL:FO that is transformed to a PDF via Apache FOP and attached to the email"
    end
    attribute :from_address, :string, public?: true
    attribute :cc_address, :string, public?: true
    attribute :bcc_address, :string, public?: true
    attribute :subject, :string, public?: true
    attribute :content_type, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :enumeration, UniboExPoc.Ofbiz.Common.Enumeration do
      public? true
      source_attribute :email_type
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
