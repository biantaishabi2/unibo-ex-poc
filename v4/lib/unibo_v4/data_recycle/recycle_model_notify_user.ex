# Workflow: recycle_model_notify_user_management — 回收规则通知用户关联维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.DataRecycle.RecycleModelNotifyUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.DataRecycle,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "data_recycle_recycle_model_notify_users"
    repo UniboV4.Repo
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
  end

  relationships do
    belongs_to :recycle_model, UniboV4.DataRecycle.RecycleModel do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.DataRecycle.ResUser do
      public? true
      allow_nil? false
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
      # TODO: 不支持的 action 内校验规则 custom
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

end
