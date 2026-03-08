defmodule UniboV4.Repair do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Repair.RepairTicket
    resource UniboV4.Repair.RepairTicket.Version
    resource UniboV4.Repair.RepairLine
    resource UniboV4.Repair.RepairLine.Version
    resource UniboV4.Repair.RepairFee
    resource UniboV4.Repair.RepairFee.Version
    resource UniboV4.Repair.RepairTag
    resource UniboV4.Repair.RepairTag.Version
    resource UniboV4.Repair.Warranty
    resource UniboV4.Repair.Warranty.Version
    resource UniboV4.Repair.Party
  end
end
