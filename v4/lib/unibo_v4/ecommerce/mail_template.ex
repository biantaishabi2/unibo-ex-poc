defmodule UniboV4.Ecommerce.MailTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_mail_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_mail_template

    queries do
      get :get_ecommerce_mail_template, :read
      list :list_ecommerce_mail_templates, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
