defmodule UniboExPoc.PLM do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.PLM.EcoType
    resource UniboExPoc.PLM.EcoType.Version
    resource UniboExPoc.PLM.EcoStage
    resource UniboExPoc.PLM.EcoStage.Version
    resource UniboExPoc.PLM.EcoStageApprovalTemplate
    resource UniboExPoc.PLM.EcoStageApprovalTemplate.Version
    resource UniboExPoc.PLM.Eco
    resource UniboExPoc.PLM.Eco.Version
    resource UniboExPoc.PLM.EcoTag
    resource UniboExPoc.PLM.EcoApproval
    resource UniboExPoc.PLM.EcoApproval.Version
    resource UniboExPoc.PLM.BomRevision
    resource UniboExPoc.PLM.EcoTypeStageLink
    resource UniboExPoc.PLM.EcoTagLink
    resource UniboExPoc.PLM.ProductTemplate
    resource UniboExPoc.PLM.MrpBom
    resource UniboExPoc.PLM.Party
  end
end
