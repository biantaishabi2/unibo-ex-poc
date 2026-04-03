defmodule UniboExPoc.Approvals do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Approvals.ApprovalTemplate
    resource UniboExPoc.Approvals.ApprovalTemplate.Version
    resource UniboExPoc.Approvals.ApprovalInstance
    resource UniboExPoc.Approvals.ApprovalInstance.Version
    resource UniboExPoc.Approvals.ApprovalTodo
    resource UniboExPoc.Approvals.ApprovalTodo.Version
    resource UniboExPoc.Approvals.ApprovalCcEntry
    resource UniboExPoc.Approvals.ApprovalCcEntry.Version
    resource UniboExPoc.Approvals.ApprovalFlowDefinition
    resource UniboExPoc.Approvals.ApprovalFlowDefinition.Version
    resource UniboExPoc.Approvals.ApprovalFlowVersion
    resource UniboExPoc.Approvals.ApprovalFlowVersion.Version
    resource UniboExPoc.Approvals.ApprovalCategory
    resource UniboExPoc.Approvals.ApprovalCategory.Version
    resource UniboExPoc.Approvals.ApprovalRequest
    resource UniboExPoc.Approvals.ApprovalRequest.Version
    resource UniboExPoc.Approvals.Approver
    resource UniboExPoc.Approvals.Approver.Version
    resource UniboExPoc.Approvals.Party
  end
end
