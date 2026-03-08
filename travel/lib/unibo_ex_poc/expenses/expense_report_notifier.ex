defmodule UniboExPoc.Expenses.ExpenseReport.Notifier do
  use Ash.Notifier

  @impl true
  def notify(%Ash.Notifier.Notification{action: %{name: action_name}} = notification) do
    topic = case action_name do
      :submit -> "expenses.report.submitted"
      :approve -> "expenses.report.approved"
      :refuse -> "expenses.report.refused"
      :post -> "expenses.report.posted"
      :register_payment -> "expenses.report.paid"
      :reset -> "expenses.report.reset"
      _ -> nil
    end

    if topic do
      Phoenix.PubSub.broadcast(UniboExPoc.PubSub, topic, {action_name, notification.data})
    end

    :ok
  end
end
