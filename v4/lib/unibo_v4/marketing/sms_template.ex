# Workflow: sms_template_maintain_flow — 短信模板维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> create_sidebar_action
#   update --> [*]
#   create_sidebar_action --> [*]
# ```
defmodule UniboV4.Marketing.SmsTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_sms_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_sms_template

    queries do
      get :get_marketing_sms_template, :read
      list :list_marketing_sms_templates, :read
    end

    mutations do
      create :create_marketing_sms_template, :create
      update :update_marketing_sms_template, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :model, :string do
      allow_nil? false
      public? true
    end
    attribute :body, :string do
      allow_nil? false
      public? true
    end
    attribute :sidebar_action_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :model_id, :body]
      validate present(:name)
      validate present(:body)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect compute
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :body]
      # skipped: validate present :body (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute
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
    action :render do
      argument :record_ids, :string
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
    action :create_sidebar_action do
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
    action :unlink_sidebar_action do
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
