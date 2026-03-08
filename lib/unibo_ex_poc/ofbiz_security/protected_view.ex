defmodule UniboV4.Ofbiz.Security.ProtectedView do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Security,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Defines views protected from data leakage"
  end

  postgres do
    table "security_protected_views"
    repo UniboV4.Repo
  end

  graphql do
    type :security_protected_view

    queries do
      get :get_security_protected_view, :read
      list :list_security_protected_views, :read
    end

    mutations do
      create :create_security_protected_view, :create
      update :update_security_protected_view, :update
      destroy :delete_security_protected_view, :destroy
    end

  end

  attributes do
    attribute :view_name_id, :string do
      primary_key? true
      allow_nil? false
      public? true
      description "name of view to protect from data theft"
    end
    attribute :max_hits, :integer do
      public? true
      description "number of hits before tarpitting a login for a view"
    end
    attribute :max_hits_duration, :integer do
      public? true
      description "period of time associated with maxHits (in seconds)"
    end
    attribute :tarpit_duration, :integer do
      public? true
      description "period of time a login will not be able to acces  this view again (in seconds)"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :security_group, UniboV4.Ofbiz.Security.SecurityGroup do
      public? true
      source_attribute :group_id
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
