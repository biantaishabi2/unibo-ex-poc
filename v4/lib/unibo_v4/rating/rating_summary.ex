defmodule UniboV4.Rating.RatingSummary do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Rating.RatingSummary.Notifier]

  postgres do
    table "rating_summaries"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :resource_type, :string do
      allow_nil? false
      public? true
    end
    attribute :resource_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :average_score, :decimal do
      default 0.0
      public? true
    end
    attribute :total_count, :integer do
      default 0
      public? true
    end
    attribute :star_1_count, :integer do
      default 0
      public? true
    end
    attribute :star_2_count, :integer do
      default 0
      public? true
    end
    attribute :star_3_count, :integer do
      default 0
      public? true
    end
    attribute :star_4_count, :integer do
      default 0
      public? true
    end
    attribute :star_5_count, :integer do
      default 0
      public? true
    end
    attribute :last_rating_at, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :satisfaction_rate
  end

  actions do
    defaults [:read]
    update :recalculate do
      accept [:average_score, :total_count, :star_1_count, :star_2_count, :star_3_count, :star_4_count, :star_5_count, :last_rating_at]
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
    identity :unique_resource, [:resource_type, :resource_id]
  end

end
