defmodule UniboV4.Ofbiz.Service do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ofbiz.Service.JobSandbox
    resource UniboV4.Ofbiz.Service.JobSandbox.Version
    resource UniboV4.Ofbiz.Service.RecurrenceInfo
    resource UniboV4.Ofbiz.Service.RecurrenceInfo.Version
    resource UniboV4.Ofbiz.Service.RecurrenceRule
    resource UniboV4.Ofbiz.Service.RecurrenceRule.Version
    resource UniboV4.Ofbiz.Service.RuntimeData
    resource UniboV4.Ofbiz.Service.RuntimeData.Version
    resource UniboV4.Ofbiz.Service.TemporalExpression
    resource UniboV4.Ofbiz.Service.TemporalExpression.Version
    resource UniboV4.Ofbiz.Service.TemporalExpressionAssoc
    resource UniboV4.Ofbiz.Service.TemporalExpressionAssoc.Version
    resource UniboV4.Ofbiz.Service.JobManagerLock
    resource UniboV4.Ofbiz.Service.JobManagerLock.Version
    resource UniboV4.Ofbiz.Service.ServiceSemaphore
    resource UniboV4.Ofbiz.Service.ServiceSemaphore.Version
  end
end
