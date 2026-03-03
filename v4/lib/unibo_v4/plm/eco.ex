# Workflow: eco_lifecycle — ECO 全生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> advance_stage
#   advance_stage --> advance_stage
#   advance_stage --> apply_changes
#   advance_stage --> rebase
#   apply_changes --> [*] : changes_applied
#   rebase --> advance_stage
# ```
defmodule UniboV4.PLM.Eco do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.PLM.Eco.Notifier]

  postgres do
    table "plm_ecos"
    repo UniboV4.Repo
  end

  graphql do
    type :plm_eco

    queries do
      get :get_plm_eco, :read
      list :list_plm_ecos, :read
    end

    mutations do
      create :create_plm_eco, :create
      update :update_plm_eco, :update
      update :advance_stage_plm_eco, :advance_stage
      update :apply_changes_plm_eco, :apply_changes
      update :rebase_plm_eco, :rebase
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :bom_revision, :integer, public?: true
    attribute :effectivity_date, :utc_datetime, public?: true
    attribute :note, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :kanban_state
    # TODO: 不支持的 calculation 表达式 :is_conflict
    # TODO: 不支持的 calculation 表达式 :allow_apply
    # TODO: 不支持的 calculation 表达式 :bom_change_ids
  end

  relationships do
    belongs_to :type, UniboV4.PLM.EcoType do
      public? true
      allow_nil? false
    end
    belongs_to :stage, UniboV4.PLM.EcoStage do
      public? true
      allow_nil? false
    end
    belongs_to :product_tmpl, UniboV4.PLM.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :bom, UniboV4.PLM.MrpBom do
      public? true
      allow_nil? false
    end
    belongs_to :new_bom, UniboV4.PLM.MrpBom do
      public? true
    end
    belongs_to :responsible, UniboV4.PLM.User do
      public? true
      allow_nil? false
    end
    many_to_many :tag_ids, UniboV4.PLM.EcoTag do
      public? true
      through UniboV4.PLM.EcoTagLink
    end
    has_many :approval_ids, UniboV4.PLM.EcoApproval do
      public? true
      destination_attribute :eco_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :note]
      argument :type_id, :uuid, allow_nil?: false
      argument :product_tmpl_id, :uuid, allow_nil?: false
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:type_id, :type, type: :append, on_lookup: :relate)
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      change manage_relationship(:product_tmpl_id, :product_tmpl, type: :append, on_lookup: :relate)
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
      argument :responsible_id, :uuid, allow_nil?: false
      change manage_relationship(:responsible_id, :responsible, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      change relate_actor(:responsible)
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
      accept [:name, :note]
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
    update :advance_stage do
      argument :target_stage_id, :uuid, allow_nil?: false
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
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
    update :apply_changes do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
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
    update :rebase do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect custom
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
