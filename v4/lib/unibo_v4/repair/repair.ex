defmodule UniboV4.Repair do
  use Ash.Domain

  resources do
    resource UniboV4.Repair.RepairTicket
    resource UniboV4.Repair.RepairLine
    resource UniboV4.Repair.RepairFee
    resource UniboV4.Repair.RepairTag
    resource UniboV4.Repair.Warranty
  end
end
