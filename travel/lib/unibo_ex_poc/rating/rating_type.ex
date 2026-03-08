# Workflow: rating_type_lifecycle — 评价类型维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Rating.RatingType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rating,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "评价类型（产品评价、服务评价、供应商评价等），泛化自 OFBiz SupplierRatingType"
  end

  postgres do
    table "rating_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rating_rating_type

    queries do
      get :get_rating_rating_type, :read
      list :list_rating_rating_types, :read
    end

    mutations do
      create :create_rating_rating_type, :create
      update :update_rating_rating_type, :update
      destroy :delete_rating_rating_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
      description "类型编码（如 product、service、supplier）"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称（对齐 SupplierRatingType.description）"
    end
    attribute :description, :string do
      public? true
      description "类型说明"
    end
    attribute :applicable_resource_types, :string do
      public? true
      description "适用的资源类型列表（逗号分隔，如 product,order,supplier）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :ratings, UniboExPoc.Rating.Rating do
      public? true
      destination_attribute :rating_type_id
    end
    has_many :criteria, UniboExPoc.Rating.RatingCriteria do
      public? true
      destination_attribute :rating_type_id
    end
    has_many :translations, UniboExPoc.Rating.RatingTypeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:code, :name, :description, :applicable_resource_types, :active]
      validate present(:code)
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
      accept [:name, :description, :applicable_resource_types, :active]
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

  identities do
    identity :unique_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:ratings, :criteria]
  end

end
