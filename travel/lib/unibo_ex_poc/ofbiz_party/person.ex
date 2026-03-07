defmodule UniboExPoc.Ofbiz.Party.Person do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Party,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "party_persons"
    repo UniboExPoc.Repo
  end

  graphql do
    type :party_person

    queries do
      get :get_party_person, :read
      list :list_party_persons, :read
    end

    mutations do
      create :create_party_person, :create
      update :update_party_person, :update
      destroy :delete_party_person, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :salutation, :string do
      public? true
      description "称谓"
    end
    attribute :first_name, :string do
      public? true
      description "名"
    end
    attribute :middle_name, :string do
      public? true
      description "中间名"
    end
    attribute :last_name, :string do
      public? true
      description "姓"
    end
    attribute :personal_title, :string do
      public? true
      description "个人称谓"
    end
    attribute :suffix, :string do
      public? true
      description "后缀"
    end
    attribute :nickname, :string do
      public? true
      description "昵称"
    end
    attribute :first_name_local, :string do
      public? true
      description "本地名字"
    end
    attribute :middle_name_local, :string do
      public? true
      description "本地中间名"
    end
    attribute :last_name_local, :string do
      public? true
      description "本地姓氏"
    end
    attribute :other_local, :string do
      public? true
      description "本地其他"
    end
    attribute :member_id, :string do
      public? true
      description "成员编号"
    end
    attribute :gender, :boolean do
      public? true
      description "性别"
    end
    attribute :birth_date, :utc_datetime do
      public? true
      description "出生日期"
    end
    attribute :deceased_date, :utc_datetime do
      public? true
      description "去世日期"
    end
    attribute :height, :float do
      public? true
      description "身高"
    end
    attribute :weight, :float do
      public? true
      description "重量"
    end
    attribute :mothers_maiden_name, :string do
      public? true
      description "母亲婚前名"
    end
    attribute :old_marital_status_enum_id, :string do
      public? true
      description "DEPRECATED use maritalStatusTypeId instead"
    end
    attribute :social_security_number, :string do
      public? true
      description "社会保险号"
    end
    attribute :passport_number, :string do
      public? true
      description "护照号"
    end
    attribute :passport_expire_date, :utc_datetime do
      public? true
      description "护照过期日期"
    end
    attribute :total_years_work_experience, :float do
      public? true
      description "总工作年数"
    end
    attribute :comments, :string do
      public? true
      description "评论"
    end
    attribute :occupation, :string do
      public? true
      description "职业"
    end
    attribute :years_with_employer, :integer do
      public? true
      description "与雇主共事年数"
    end
    attribute :months_with_employer, :integer do
      public? true
      description "与雇主共事月数"
    end
    attribute :existing_customer, :boolean do
      public? true
      description "现有客户"
    end
    attribute :card_id, :string do
      public? true
      description "卡编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.Party.Party do
      public? true
    end
    belongs_to :employment_status_enumeration, UniboExPoc.Ofbiz.Party.Enumeration do
      public? true
      source_attribute :employment_status_enum_id
    end
    belongs_to :residence_status_enumeration, UniboExPoc.Ofbiz.Party.Enumeration do
      public? true
      source_attribute :residence_status_enum_id
    end
    belongs_to :marital_status_type, UniboExPoc.Ofbiz.Party.MaritalStatusType do
      public? true
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
