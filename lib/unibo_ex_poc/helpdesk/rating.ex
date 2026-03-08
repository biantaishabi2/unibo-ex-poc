# Workflow: rating_lifecycle — 评分记录生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reset
#   update --> update
#   update --> reset
#   reset --> update
# ```
defmodule UniboV4.Helpdesk.Rating do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "评分记录，泛型关联任意被评分对象（res_model/res_id），支持满意度统计"
  end

  postgres do
    table "helpdesk_ratings"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_rating

    queries do
      get :get_helpdesk_rating, :read
      list :list_helpdesk_ratings, :read
    end

    mutations do
      create :create_helpdesk_rating, :create
      update :update_helpdesk_rating, :update
      update :reset_helpdesk_rating, :reset
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :res_model, :string do
      allow_nil? false
      public? true
      description "被评分对象的模型名称（泛型关联，如 HelpdeskTicket）"
    end
    attribute :res_id, :uuid do
      allow_nil? false
      public? true
      description "被评分对象的记录 ID"
    end
    attribute :res_name, :string do
      public? true
      description "被评分对象名称（计算字段，从关联记录获取）"
    end
    attribute :parent_res_model, :string do
      public? true
      description "父对象模型名称（如工单的所属团队）"
    end
    attribute :parent_res_id, :uuid do
      public? true
      description "父对象记录 ID"
    end
    attribute :rating, :decimal do
      default 0
      public? true
      description "评分值（0-5），group_operator=avg"
    end
    attribute :rating_text, :atom do
      constraints one_of: [:top, :ok, :ko, :none]
      default :none
      public? true
      description "评分等级文本（>=4=top, >=3=ok, >=1=ko, <1=none）"
    end
    attribute :feedback, :string do
      public? true
      description "客户反馈文本"
    end
    attribute :consumed, :boolean do
      default false
      public? true
      description "是否已消费（已被统计使用）"
    end
    attribute :access_token, :string do
      public? true
      description "评分链接的 UUID 访问令牌"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :ticket, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      source_attribute :helpdesk_ticket_id
    end
    belongs_to :rated_partner, UniboV4.Helpdesk.Party do
      public? true
      source_attribute :rated_partner_party_id
    end
    belongs_to :partner, UniboV4.Helpdesk.Party do
      public? true
      source_attribute :partner_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:res_model, :res_id, :parent_res_model, :parent_res_id, :rating, :feedback, :helpdesk_ticket_id]
      argument :rated_partner_id, :uuid
      argument :partner_id, :uuid
      validate present(:res_model)
      validate present(:res_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:rating, :feedback, :consumed]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reset do
      description "重置评分（清零分值，生成新访问令牌，清空反馈）"
      accept []
      change set_attribute(:rating, 0)
      change set_attribute(:consumed, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:rating, greater_than_or_equal_to: 0)
    validate compare(:rating, less_than_or_equal_to: 5)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
