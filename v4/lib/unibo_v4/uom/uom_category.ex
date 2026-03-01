defmodule UniboV4.Uom.UomCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Uom,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "uom_uom_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :uom_uom_category

    queries do
      get :get_uom_uom_category, :read
      list :list_uom_uom_categorys, :read
    end

    mutations do
      create :create_uom_uom_category, :create
      update :update_uom_uom_category, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :uoms, UniboV4.Uom.Uom do
      public? true
      destination_attribute :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name]
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
      accept [:name]
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
