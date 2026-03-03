defmodule UniboV4.PipelineTest.TestItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PipelineTest,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "pipeline_test_test_items"
    repo UniboV4.Repo
  end

  graphql do
    type :pipeline_test_test_item

    queries do
      get :get_pipeline_test_test_item, :read
      list :list_pipeline_test_test_items, :read
    end

    mutations do
      create :create_pipeline_test_test_item, :create
      update :update_pipeline_test_test_item, :update
      destroy :delete_pipeline_test_test_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, public?: true
    attribute :status, :string, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      accept [:title]
    end
    update :update do
      primary? true
      accept [:title, :status]
    end
  end

end
