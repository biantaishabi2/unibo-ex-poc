# Workflow: eco_tag_creation_flow — ECO 标签创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.PLM.EcoTag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "ECO 标签，用于分类和筛选"
  end

  postgres do
    table "plm_eco_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco_tag

    queries do
      get :get_plm_eco_tag, :read
      list :list_plm_eco_tags, :read
    end

    mutations do
      create :create_plm_eco_tag, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称"
    end
    attribute :color, :string do
      public? true
      description "标签颜色"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:name, :color]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_eco_tag_name, [:name]
  end

end
