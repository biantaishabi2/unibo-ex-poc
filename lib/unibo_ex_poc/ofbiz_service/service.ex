defmodule UniboExPoc.Ofbiz.Service do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Service.JobSandbox
    resource UniboExPoc.Ofbiz.Service.JobSandbox.Version
    resource UniboExPoc.Ofbiz.Service.RecurrenceInfo
    resource UniboExPoc.Ofbiz.Service.RecurrenceInfo.Version
    resource UniboExPoc.Ofbiz.Service.RecurrenceRule
    resource UniboExPoc.Ofbiz.Service.RecurrenceRule.Version
    resource UniboExPoc.Ofbiz.Service.RuntimeData
    resource UniboExPoc.Ofbiz.Service.RuntimeData.Version
    resource UniboExPoc.Ofbiz.Service.TemporalExpression
    resource UniboExPoc.Ofbiz.Service.TemporalExpression.Version
    resource UniboExPoc.Ofbiz.Service.TemporalExpressionAssoc
    resource UniboExPoc.Ofbiz.Service.TemporalExpressionAssoc.Version
    resource UniboExPoc.Ofbiz.Service.JobManagerLock
    resource UniboExPoc.Ofbiz.Service.JobManagerLock.Version
    resource UniboExPoc.Ofbiz.Service.ServiceSemaphore
    resource UniboExPoc.Ofbiz.Service.ServiceSemaphore.Version
  end
end
