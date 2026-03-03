defmodule UniboV4.PipelineTest do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.PipelineTest.TestItem
  end
end
