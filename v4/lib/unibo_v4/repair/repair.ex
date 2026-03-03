defmodule UniboV4.Repair.Repair do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Repair.Repair.RepairTicket
    resource UniboV4.Repair.Repair.RepairLine
    resource UniboV4.Repair.Repair.RepairFee
    resource UniboV4.Repair.Repair.RepairTag
    resource UniboV4.Repair.Repair.Warranty
  end
end
