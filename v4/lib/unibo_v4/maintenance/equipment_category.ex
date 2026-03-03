# Workflow: equipment_category_maintain_flow — 设备分类维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Maintenance.EquipmentCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_equipment_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_equipment_category

    queries do
      get :get_maintenance_equipment_category, :read
      list :list_maintenance_equipment_categorys, :read
    end

    mutations do
      create :create_maintenance_equipment_category, :create
      update :update_maintenance_equipment_category, :update
      destroy :delete_maintenance_equipment_category, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :alias_name, :string, public?: true
    attribute :maintenance_count, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :equipment_list, UniboV4.Maintenance.Equipment do
      public? true
      destination_attribute :category_ref_id
    end
    has_many :maintenance_requests, UniboV4.Maintenance.MaintenanceRequest do
      public? true
      destination_attribute :category_id
    end
    belongs_to :technician, UniboV4.Maintenance.User do
      public? true
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :alias_name]
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 change effect create_mail_alias
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
      accept [:name, :alias_name]
      # TODO: 不支持的 change effect create_mail_alias
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

  validations do
    # TODO: 不支持的校验规则 company_member
  end

end
