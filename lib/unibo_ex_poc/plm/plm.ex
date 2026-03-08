defmodule UniboV4.PLM do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.PLM.EcoType
    resource UniboV4.PLM.EcoType.Version
    resource UniboV4.PLM.EcoStage
    resource UniboV4.PLM.EcoStage.Version
    resource UniboV4.PLM.EcoStageApprovalTemplate
    resource UniboV4.PLM.EcoStageApprovalTemplate.Version
    resource UniboV4.PLM.Eco
    resource UniboV4.PLM.Eco.Version
    resource UniboV4.PLM.EcoTag
    resource UniboV4.PLM.EcoApproval
    resource UniboV4.PLM.EcoApproval.Version
    resource UniboV4.PLM.BomRevision
    resource UniboV4.PLM.EcoTypeStageLink
    resource UniboV4.PLM.EcoTagLink
    resource UniboV4.PLM.ProductTemplate
    resource UniboV4.PLM.MrpBom
    resource UniboV4.PLM.Party
  end
end
