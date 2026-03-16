defmodule UniboExPoc.Accounting.Bdd.InstructionSourcesGenerated do
  @moduledoc false

  # 自动生成：供 bddc registry.scaffold --standalone 扫描
  # 请勿手动修改（由 unibo compile 输出）

  @bdd_instruction %{name: :unibo_accounting_gl_account_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_gl_account_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_gl_account_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_gl_account_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_gl_account_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_gl_account_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_gl_account_action_deactivate, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_gl_account_action_deactivate__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_gl_account_workflow_gl_account_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_gl_account_workflow_gl_account_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_journal_entry_action_create,
    kind: :when,
    args: %{
      lines: %{type: :string, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_accounting_journal_entry_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_action_post, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_action_post__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_action_cancel, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_action_cancel__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_action_reset_to_draft, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_action_reset_to_draft__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_event_post_accounting_journal_posted, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_event_post_accounting_journal_posted__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_event_cancel_accounting_journal_cancelled, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_event_cancel_accounting_journal_cancelled__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_event_reset_to_draft_accounting_journal_reset_to_draft, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_event_reset_to_draft_accounting_journal_reset_to_draft__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_workflow_journal_entry_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_workflow_journal_entry_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_journal_entry_line_action_create,
    kind: :when,
    args: %{
      gl_account_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_accounting_journal_entry_line_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_line_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_line_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_line_workflow_journal_entry_line_editing, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_line_workflow_journal_entry_line_editing__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_invoice_action_create,
    kind: :when,
    args: %{
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
  def __bdd_instruction_unibo_accounting_invoice_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_action_approve, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_action_approve__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_action_send, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_action_send__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_action_void, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_action_void__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_event_approve_accounting_invoice_approved, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_event_approve_accounting_invoice_approved__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_event_send_accounting_invoice_sent, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_event_send_accounting_invoice_sent__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_workflow_invoice_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_workflow_invoice_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_invoice_item_action_create,
    kind: :when,
    args: %{
      gl_account_id: %{type: :uuid, required?: false, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_accounting_invoice_item_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_item_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_item_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_invoice_item_workflow_invoice_item_editing, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_invoice_item_workflow_invoice_item_editing__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_action_post, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_action_post__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_action_cancel, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_action_cancel__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_action_reset_to_draft, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_action_reset_to_draft__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_event_post_accounting_payment_posted, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_event_post_accounting_payment_posted__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_event_cancel_accounting_payment_cancelled, kind: :then, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_event_cancel_accounting_payment_cancelled__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_workflow_payment_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_workflow_payment_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_payment_application_action_create,
    kind: :when,
    args: %{
      invoice_id: %{type: :uuid, required?: true, allowed: nil},
      payment_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_accounting_payment_application_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_application_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_application_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_application_action_destroy, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_application_action_destroy__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_payment_application_workflow_payment_application_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_payment_application_workflow_payment_application_lifecycle__, do: :ok

  @bdd_instruction %{
    name: :unibo_accounting_partial_reconcile_action_create,
    kind: :when,
    args: %{
      credit_line_id: %{type: :uuid, required?: true, allowed: nil},
      debit_line_id: %{type: :uuid, required?: true, allowed: nil},
    },
    outputs: %{},
    rules: [],
    scopes: [:integration, :e2e],
    boundary: :service,
    async?: false,
    eventually?: false,
    assert_class: nil
  }
  def __bdd_instruction_unibo_accounting_partial_reconcile_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_partial_reconcile_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_partial_reconcile_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_partial_reconcile_action_destroy, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_partial_reconcile_action_destroy__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_partial_reconcile_workflow_reconciliation_flow, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_partial_reconcile_workflow_reconciliation_flow__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_full_reconcile_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_full_reconcile_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_full_reconcile_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_full_reconcile_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_full_reconcile_action_destroy, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_full_reconcile_action_destroy__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_full_reconcile_workflow_full_reconcile_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_full_reconcile_workflow_full_reconcile_lifecycle__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_billing_account_action_create, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_billing_account_action_create__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_billing_account_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_billing_account_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_billing_account_action_update, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_billing_account_action_update__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_billing_account_workflow_billing_account_lifecycle, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_billing_account_workflow_billing_account_lifecycle__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_tax_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_tax_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_journal_entry_line_tax_rel_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_journal_entry_line_tax_rel_action_read__, do: :ok

  @bdd_instruction %{name: :unibo_accounting_party_action_read, kind: :when, args: %{}, outputs: %{}, rules: [], scopes: [:integration, :e2e], boundary: :service, async?: false, eventually?: false, assert_class: nil}
  def __bdd_instruction_unibo_accounting_party_action_read__, do: :ok

end
