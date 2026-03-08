defmodule UniboV4.Documents do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Documents.Document
    resource UniboV4.Documents.Document.Version
    resource UniboV4.Documents.Folder
    resource UniboV4.Documents.Folder.Version
    resource UniboV4.Documents.Tag
    resource UniboV4.Documents.Tag.Version
    resource UniboV4.Documents.Facet
    resource UniboV4.Documents.Facet.Version
    resource UniboV4.Documents.WorkflowRule
    resource UniboV4.Documents.WorkflowRule.Version
    resource UniboV4.Documents.Share
    resource UniboV4.Documents.Share.Version
    resource UniboV4.Documents.Group
    resource UniboV4.Documents.Contact
    resource UniboV4.Documents.Attachment
    resource UniboV4.Documents.MailAlias
    resource UniboV4.Documents.ActivityType
    resource UniboV4.Documents.DocumentVersion
    resource UniboV4.Documents.DocumentTagLink
    resource UniboV4.Documents.DocumentFavoriteLink
    resource UniboV4.Documents.DocumentGroupLink
    resource UniboV4.Documents.DocumentShareLink
    resource UniboV4.Documents.FolderWorkflowRuleLink
    resource UniboV4.Documents.FolderReadGroupLink
    resource UniboV4.Documents.FolderWriteGroupLink
    resource UniboV4.Documents.ShareTagLink
    resource UniboV4.Documents.WorkflowRuleRequiredTagLink
    resource UniboV4.Documents.WorkflowRuleExcludedTagLink
    resource UniboV4.Documents.WorkflowRuleTagActionLink
    resource UniboV4.Documents.WorkflowRuleRemoveTagLink
    resource UniboV4.Documents.Party
  end
end
