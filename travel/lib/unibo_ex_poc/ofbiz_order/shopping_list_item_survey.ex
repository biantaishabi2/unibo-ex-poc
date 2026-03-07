defmodule UniboExPoc.Ofbiz.Order.ShoppingListItemSurvey do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_shopping_list_item_surveys"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_shopping_list_item_survey

    queries do
      get :get_order_shopping_list_item_survey, :read
      list :list_order_shopping_list_item_surveys, :read
    end

    mutations do
      create :create_order_shopping_list_item_survey, :create
      update :update_order_shopping_list_item_survey, :update
      destroy :delete_order_shopping_list_item_survey, :destroy
    end

  end

  attributes do
    attribute :shopping_list_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :survey_response_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shopping_list, UniboExPoc.Ofbiz.Order.ShoppingList do
      public? true
      attribute_type :string
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
