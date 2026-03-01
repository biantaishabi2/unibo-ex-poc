defmodule UniboV4.Sales.Sales.Bdd.InstructionSourcesGenerated do
  @moduledoc false

  # 自动生成：供 bddc registry.scaffold --standalone 扫描
  # 请勿手动修改（由 unibo compile 输出）

  @bdd_instruction %{name: :unibo_sales_customer_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_action_block, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_action_block__, do: :ok

  @bdd_instruction %{name: :unibo_sales_customer_workflow_customer_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_customer_workflow_customer_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_quote_action_create,
    kind: :when,
    args: %{
      customer_id: %{type: :uuid, required?: true, allowed: nil},
      items: %{type: :string, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_quote_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_submit, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_submit__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_accept, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_accept__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_action_reject, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_action_reject__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_event_submit_sales_quote_submitted, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_event_submit_sales_quote_submitted__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_event_accept_sales_quote_accepted, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_event_accept_sales_quote_accepted__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_workflow_quote_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_workflow_quote_lifecycle__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_item_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_item_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_item_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_item_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_quote_item_workflow_quote_item_editing, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_quote_item_workflow_quote_item_editing__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_sales_order_action_create,
    kind: :when,
    args: %{
      customer_id: %{type: :uuid, required?: true, allowed: nil},
      items: %{type: :string, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_sales_order_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_action_quotation_send, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_action_quotation_send__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_action_confirm, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_action_confirm__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_action_done, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_action_done__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_action_cancel, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_action_cancel__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_action_action_draft, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_action_action_draft__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_sales_order_action_create_invoices,
    kind: :when,
    args: %{
      final: %{type: :bool, required?: false, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_sales_order_action_create_invoices__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_action_quotation_send_sales_order_sent, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_action_quotation_send_sales_order_sent__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_action_confirm_sales_order_confirmed, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_action_confirm_sales_order_confirmed__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_action_done_sales_order_done, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_action_done_sales_order_done__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_action_cancel_sales_order_cancelled, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_action_cancel_sales_order_cancelled__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_action_draft_sales_order_reset_to_draft, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_action_draft_sales_order_reset_to_draft__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_event_create_invoices_sales_order_invoice_created, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_event_create_invoices_sales_order_invoice_created__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_workflow_sales_order_lifecycle_flow, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_workflow_sales_order_lifecycle_flow__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_workflow_sales_order_reopen_flow, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_workflow_sales_order_reopen_flow__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_workflow_pricing_chain, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_workflow_pricing_chain__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_workflow_order_item_editing, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_workflow_order_item_editing__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_sales_order_shipment_action_create,
    kind: :when,
    args: %{
      sales_order_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_ship, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_ship__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_action_deliver, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_action_deliver__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_event_ship_sales_shipment_shipped, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_event_ship_sales_shipment_shipped__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_event_deliver_sales_shipment_delivered, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_event_deliver_sales_shipment_delivered__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_shipment_workflow_shipment_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_shipment_workflow_shipment_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_return_action_create,
    kind: :when,
    args: %{
      customer_id: %{type: :uuid, required?: true, allowed: nil},
      items: %{type: :string, required?: true, allowed: nil},
      sales_order_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_return_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_approve, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_approve__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_receive, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_receive__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_complete, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_complete__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_action_cancel, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_action_cancel__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_event_approve_sales_return_approved, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_event_approve_sales_return_approved__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_event_complete_sales_return_completed, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_event_complete_sales_return_completed__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_workflow_return_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_workflow_return_lifecycle__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_item_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_item_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_item_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_item_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_return_item_workflow_return_item_editing, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_return_item_workflow_return_item_editing__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_delivery_carrier_action_create,
    kind: :when,
    args: %{
      product_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_delivery_carrier_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_action_destroy, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_action_destroy__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_delivery_carrier_action_rate_shipment,
    kind: :when,
    args: %{
      order_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_delivery_carrier_action_rate_shipment__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_carrier_workflow_delivery_carrier_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_carrier_workflow_delivery_carrier_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_sales_delivery_price_rule_action_create,
    kind: :when,
    args: %{
      carrier_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_action_destroy, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_action_destroy__, do: :ok

  @bdd_instruction %{name: :unibo_sales_delivery_price_rule_workflow_price_rule_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_delivery_price_rule_workflow_price_rule_lifecycle__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_user_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_user_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_product_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_product_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_tax_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_tax_action_lookup__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_list, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_list__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_search, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_search__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_get, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_get__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_preview, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_preview__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_compute, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_compute__, do: :ok

  @bdd_instruction %{name: :unibo_sales_sales_order_item_tax_rel_action_lookup, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_sales_sales_order_item_tax_rel_action_lookup__, do: :ok

end
