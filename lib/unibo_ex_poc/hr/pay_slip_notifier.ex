defmodule UniboV4.HR.PaySlip.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :create -> "hr.payslip.created"
      :compute_sheet -> "hr.payslip.verified"
      :action_payslip_done -> "hr.payslip.done"
      :action_payslip_paid -> "hr.payslip.paid"
      :action_payslip_cancel -> "hr.payslip.cancelled"
      :refund_sheet -> "hr.payslip.refunded"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboV4.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
