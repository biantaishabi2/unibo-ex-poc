# Workflow: recycle_model_notify_user_management — 回收规则通知用户关联维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.DataRecycle.RecycleModelNotifyUser do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.DataRecycle,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "回收规则通知用户关联表——多对多桥接"
  end

  postgres do
    table "data_recycle_recycle_model_notify_users"
    repo UniboExPoc.Repo
  end

  graphql do
    type :data_recycle_recycle_model_notify_user

    queries do
      get :get_data_recycle_recycle_model_notify_user, :read
      list :list_data_recycle_recycle_model_notify_users, :read
    end

    mutations do
      create :create_data_recycle_recycle_model_notify_user, :create
      destroy :delete_data_recycle_recycle_model_notify_user, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :recycle_model, UniboExPoc.DataRecycle.RecycleModel do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.DataRecycle.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :destroy, :update]
    create :create do
      primary? true
      accept []
      argument :recycle_model_id, :uuid, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:recycle_model_id, :recycle_model, type: :append, on_lookup: :relate)
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present([:recycle_model_id, :user_id])
      # message: "recycle_model_id 和 user_id 必须传入"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
