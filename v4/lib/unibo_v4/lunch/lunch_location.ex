# Workflow: location_management — 配送地点管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Lunch.LunchLocation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_locations"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :address, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :address]
      validate present(:name)
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
      accept [:name, :address]
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

end
