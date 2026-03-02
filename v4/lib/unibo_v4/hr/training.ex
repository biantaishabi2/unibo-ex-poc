defmodule UniboV4.HR.Training do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "trainings"
    repo UniboV4.Repo
  end

  graphql do
    type :training

    queries do
      get :get_training, :read
      list :list_trainings, :read
    end

    mutations do
      create :create_training, :create
      update :complete_training, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :training_name, :string, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:planned, :in_progress, :completed, :cancelled]
      default :planned
        public? true
    end
    attribute :start_date, :date, allow_nil?: false, public?: true
    attribute :end_date, :date, public?: true
    attribute :score, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:training_name, :start_date, :end_date, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:training_name)
    end
    update :complete do
      accept [:score]
      validate attribute_in(:status, [:planned, :in_progress]) do
        message "只有计划中或进行中的培训可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

end
