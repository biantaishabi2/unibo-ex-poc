defmodule UniboV4.HR.Skill do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "skills"
    repo UniboV4.Repo
  end

  graphql do
    type :skill

    queries do
      get :get_skill, :read
      list :list_skills, :read
    end

    mutations do
      create :create_skill, :create
      update :update_skill, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :category, :string, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :category, :description]
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :category, :description]
    end
  end

end
