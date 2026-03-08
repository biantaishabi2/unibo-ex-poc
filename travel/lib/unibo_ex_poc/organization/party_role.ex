defmodule UniboExPoc.Organization.PartyRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Organization,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "主体角色，同一主体可以同时拥有多个角色（如既是员工又是质量检查员）"
  end

  postgres do
    table "organization_party_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :organization_party_role

    queries do
      get :get_organization_party_role, :read
      list :list_organization_party_roles, :read
    end

    mutations do
      create :create_organization_party_role, :create
      update :update_organization_party_role, :update
      destroy :delete_organization_party_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role_type, :atom do
      allow_nil? false
      constraints one_of: [:employee, :customer, :supplier, :factory, :department, :team, :admin, :quality_inspector, :rental_agent, :sales_rep, :project_manager]
      public? true
      description "角色类型，可扩展"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Organization.Party do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role_type]
      argument :party_id, :uuid, allow_nil?: false
      change manage_relationship(:party_id, :party, type: :append, on_lookup: :relate)
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
      accept [:role_type]
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
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
