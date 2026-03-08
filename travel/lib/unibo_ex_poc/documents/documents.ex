defmodule UniboExPoc.Documents do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Documents.Document
    resource UniboExPoc.Documents.Document.Version
    resource UniboExPoc.Documents.Folder
    resource UniboExPoc.Documents.Folder.Version
    resource UniboExPoc.Documents.Tag
    resource UniboExPoc.Documents.Tag.Version
    resource UniboExPoc.Documents.Facet
    resource UniboExPoc.Documents.Facet.Version
    resource UniboExPoc.Documents.WorkflowRule
    resource UniboExPoc.Documents.WorkflowRule.Version
    resource UniboExPoc.Documents.Share
    resource UniboExPoc.Documents.Share.Version
    resource UniboExPoc.Documents.Group
    resource UniboExPoc.Documents.Contact
    resource UniboExPoc.Documents.Attachment
    resource UniboExPoc.Documents.MailAlias
    resource UniboExPoc.Documents.ActivityType
    resource UniboExPoc.Documents.DocumentVersion
    resource UniboExPoc.Documents.DocumentTagLink
    resource UniboExPoc.Documents.DocumentFavoriteLink
    resource UniboExPoc.Documents.DocumentGroupLink
    resource UniboExPoc.Documents.DocumentShareLink
    resource UniboExPoc.Documents.FolderWorkflowRuleLink
    resource UniboExPoc.Documents.FolderReadGroupLink
    resource UniboExPoc.Documents.FolderWriteGroupLink
    resource UniboExPoc.Documents.ShareTagLink
    resource UniboExPoc.Documents.WorkflowRuleRequiredTagLink
    resource UniboExPoc.Documents.WorkflowRuleExcludedTagLink
    resource UniboExPoc.Documents.WorkflowRuleTagActionLink
    resource UniboExPoc.Documents.WorkflowRuleRemoveTagLink
    resource UniboExPoc.Documents.Party
  end
end
