defmodule UniboV4.Uom.Uom do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Uom,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "uom_uoms"
    repo UniboV4.Repo
  end

  graphql do
    type :uom_uom

    queries do
      get :get_uom_uom, :read
      list :list_uom_uoms, :read
      get :get_compute_quantity_uom_uom, :compute_quantity
      list :list_compute_quantity_uom_uoms, :compute_quantity
      get :get_compute_price_uom_uom, :compute_price
      list :list_compute_price_uom_uoms, :compute_price
    end

    mutations do
      create :create_uom_uom, :create
      update :update_uom_uom, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :factor, :float do
      allow_nil? false
      default 1.0
      public? true
    end
    attribute :rounding, :float do
      default 0.01
      public? true
    end
    attribute :uom_type, :atom do
      allow_nil? false
      constraints one_of: [:bigger, :reference, :smaller]
      default :reference
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :factor_inv
    # TODO: 不支持的 calculation 表达式 :ratio
  end

  relationships do
    belongs_to :category, UniboV4.Uom.UomCategory do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :factor, :rounding, :uom_type, :active]
      argument :category_id, :uuid, allow_nil?: false
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
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
    update :update do
      primary? true
      accept [:name, :factor, :rounding, :uom_type, :active]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    read :compute_quantity do
      argument :qty, :decimal, allow_nil?: false
      argument :to_unit_id, :uuid, allow_nil?: false
      argument :round, :boolean
    end
    read :compute_price do
      argument :price, :decimal, allow_nil?: false
      argument :to_unit_id, :uuid, allow_nil?: false
    end
  end

  validations do
    validate compare(:rounding, greater_than: 0)
  end

end
