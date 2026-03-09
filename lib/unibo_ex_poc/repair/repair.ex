defmodule UniboExPoc.Repair do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Repair.RepairTicket
    resource UniboExPoc.Repair.RepairTicket.Version
    resource UniboExPoc.Repair.RepairLine
    resource UniboExPoc.Repair.RepairLine.Version
    resource UniboExPoc.Repair.RepairFee
    resource UniboExPoc.Repair.RepairFee.Version
    resource UniboExPoc.Repair.RepairTag
    resource UniboExPoc.Repair.RepairTag.Version
    resource UniboExPoc.Repair.Warranty
    resource UniboExPoc.Repair.Warranty.Version
    resource UniboExPoc.Repair.Party
  end
end
