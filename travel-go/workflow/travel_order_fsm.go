package workflow

import (
	"context"

	"github.com/looplab/fsm"
)

// TravelOrderTravelOrderLifecycleFSM 管理 TravelOrder 实体的 TravelOrderLifecycle 状态转换
// 统一酒旅订单生命周期，覆盖 train 候补与改签分支；退款由 Payment 域处理
// ```mermaid
// stateDiagram-v2
//   [*] --> create_order
//   create_order --> update: create_order_to_update
//   create_order --> confirm_quote: create_order_to_confirm_quote
//   create_order --> destroy: create_order_to_destroy
//   update --> confirm_quote: update_to_confirm_quote
//   update --> destroy: update_to_destroy
//   confirm_quote --> submit_order: confirm_quote_to_submit_order
//   confirm_quote --> submit_waitlist: confirm_quote_to_submit_waitlist
//   submit_order --> mark_payment_succeeded: submit_order_to_mark_payment_succeeded
//   submit_order --> mark_order_failed: submit_order_to_mark_order_failed
//   submit_waitlist --> mark_payment_succeeded: submit_waitlist_to_mark_payment_succeeded
//   submit_waitlist --> mark_order_failed: submit_waitlist_to_mark_order_failed
//   mark_payment_succeeded --> mark_booked: mark_payment_succeeded_to_mark_booked
//   mark_payment_succeeded --> fulfill_waitlist: mark_payment_succeeded_to_fulfill_waitlist
//   mark_payment_succeeded --> cancel_waitlist: mark_payment_succeeded_to_cancel_waitlist
//   mark_booked --> mark_completed: mark_booked_to_mark_completed
//   mark_booked --> request_cancel: mark_booked_to_request_cancel
//   mark_booked --> request_change: mark_booked_to_request_change
//   fulfill_waitlist --> mark_completed: fulfill_waitlist_to_mark_completed
//   fulfill_waitlist --> request_cancel: fulfill_waitlist_to_request_cancel
//   fulfill_waitlist --> request_change: fulfill_waitlist_to_request_change
//   cancel_waitlist --> request_cancel: cancel_waitlist_to_request_cancel
//   request_cancel --> approve_cancel: request_cancel_to_approve_cancel
//   approve_cancel --> request_change: approve_cancel_to_request_change
//   request_change --> confirm_change: request_change_to_confirm_change
//   confirm_change --> mark_completed: confirm_change_to_mark_completed
//   mark_completed --> mark_order_failed: mark_completed_to_mark_order_failed
//   mark_order_failed --> destroy: mark_order_failed_to_destroy
//   destroy --> [*]
// ```
type TravelOrderTravelOrderLifecycleFSM struct {
	FSM *fsm.FSM
}

// NewTravelOrderTravelOrderLifecycleFSM 创建新的 TravelOrderLifecycle 状态机实例
func NewTravelOrderTravelOrderLifecycleFSM(initialState string) *TravelOrderTravelOrderLifecycleFSM {
	o := &TravelOrderTravelOrderLifecycleFSM{}
	o.FSM = fsm.NewFSM(
		initialState,
		fsm.Events{
			{Name: "create_order_to_update", Src: []string{"create_order"}, Dst: "update"},
			{Name: "create_order_to_confirm_quote", Src: []string{"create_order"}, Dst: "confirm_quote"},
			{Name: "create_order_to_destroy", Src: []string{"create_order"}, Dst: "destroy"},
			{Name: "update_to_confirm_quote", Src: []string{"update"}, Dst: "confirm_quote"},
			{Name: "update_to_destroy", Src: []string{"update"}, Dst: "destroy"},
			{Name: "confirm_quote_to_submit_order", Src: []string{"confirm_quote"}, Dst: "submit_order"},
			{Name: "confirm_quote_to_submit_waitlist", Src: []string{"confirm_quote"}, Dst: "submit_waitlist"},
			{Name: "submit_order_to_mark_payment_succeeded", Src: []string{"submit_order"}, Dst: "mark_payment_succeeded"},
			{Name: "submit_order_to_mark_order_failed", Src: []string{"submit_order"}, Dst: "mark_order_failed"},
			{Name: "submit_waitlist_to_mark_payment_succeeded", Src: []string{"submit_waitlist"}, Dst: "mark_payment_succeeded"},
			{Name: "submit_waitlist_to_mark_order_failed", Src: []string{"submit_waitlist"}, Dst: "mark_order_failed"},
			{Name: "mark_payment_succeeded_to_mark_booked", Src: []string{"mark_payment_succeeded"}, Dst: "mark_booked"},
			{Name: "mark_payment_succeeded_to_fulfill_waitlist", Src: []string{"mark_payment_succeeded"}, Dst: "fulfill_waitlist"},
			{Name: "mark_payment_succeeded_to_cancel_waitlist", Src: []string{"mark_payment_succeeded"}, Dst: "cancel_waitlist"},
			{Name: "mark_booked_to_mark_completed", Src: []string{"mark_booked"}, Dst: "mark_completed"},
			{Name: "mark_booked_to_request_cancel", Src: []string{"mark_booked"}, Dst: "request_cancel"},
			{Name: "mark_booked_to_request_change", Src: []string{"mark_booked"}, Dst: "request_change"},
			{Name: "fulfill_waitlist_to_mark_completed", Src: []string{"fulfill_waitlist"}, Dst: "mark_completed"},
			{Name: "fulfill_waitlist_to_request_cancel", Src: []string{"fulfill_waitlist"}, Dst: "request_cancel"},
			{Name: "fulfill_waitlist_to_request_change", Src: []string{"fulfill_waitlist"}, Dst: "request_change"},
			{Name: "cancel_waitlist_to_request_cancel", Src: []string{"cancel_waitlist"}, Dst: "request_cancel"},
			{Name: "request_cancel_to_approve_cancel", Src: []string{"request_cancel"}, Dst: "approve_cancel"},
			{Name: "approve_cancel_to_request_change", Src: []string{"approve_cancel"}, Dst: "request_change"},
			{Name: "request_change_to_confirm_change", Src: []string{"request_change"}, Dst: "confirm_change"},
			{Name: "confirm_change_to_mark_completed", Src: []string{"confirm_change"}, Dst: "mark_completed"},
			{Name: "mark_completed_to_mark_order_failed", Src: []string{"mark_completed"}, Dst: "mark_order_failed"},
			{Name: "mark_order_failed_to_destroy", Src: []string{"mark_order_failed"}, Dst: "destroy"},
		},
		fsm.Callbacks{
			"enter_submit_order": func(_ context.Context, e *fsm.Event) {
				// 触发事件: submitted
			},
			"enter_submit_waitlist": func(_ context.Context, e *fsm.Event) {
				// 触发事件: waitlist_submitted
			},
			"enter_mark_payment_succeeded": func(_ context.Context, e *fsm.Event) {
				// 触发事件: payment_confirmed
			},
			"enter_fulfill_waitlist": func(_ context.Context, e *fsm.Event) {
				// 触发事件: waitlist_fulfilled
			},
			"enter_cancel_waitlist": func(_ context.Context, e *fsm.Event) {
				// 触发事件: waitlist_cancelled
			},
			"enter_approve_cancel": func(_ context.Context, e *fsm.Event) {
				// 触发事件: cancelled
			},
			"enter_confirm_change": func(_ context.Context, e *fsm.Event) {
				// 触发事件: change_confirmed
			},
			"enter_mark_order_failed": func(_ context.Context, e *fsm.Event) {
				// 触发事件: failed
			},
		},
	)
	return o
}

// DefaultInitialState 返回 TravelOrderLifecycle 的默认初始状态
func TravelOrderTravelOrderLifecycleFSMDefaultInitialState() string {
	return "create_order"
}

// TravelOrderTravelOrderLifecycleFSMWorkflowSemanticsJSON 返回编排语义快照（供跨端回放比对）
func TravelOrderTravelOrderLifecycleFSMWorkflowSemanticsJSON() string {
	return `{"steps":[{"idempotency_key":null,"next":["update","confirm_quote","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create_order"},{"idempotency_key":null,"next":["confirm_quote","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update"},{"idempotency_key":null,"next":["submit_order","submit_waitlist"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_quote"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_order"},{"idempotency_key":null,"next":["mark_payment_succeeded","mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"submit_waitlist"},{"idempotency_key":null,"next":["mark_booked","fulfill_waitlist","cancel_waitlist"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_payment_succeeded"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_booked"},{"idempotency_key":null,"next":["mark_completed","request_cancel","request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"fulfill_waitlist"},{"idempotency_key":null,"next":["request_cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel_waitlist"},{"idempotency_key":null,"next":["approve_cancel"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_cancel"},{"idempotency_key":null,"next":["request_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"approve_cancel"},{"idempotency_key":null,"next":["confirm_change"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"request_change"},{"idempotency_key":null,"next":["mark_completed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_change"},{"idempotency_key":null,"next":["mark_order_failed"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_completed"},{"idempotency_key":null,"next":["destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_order_failed"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"destroy"}],"workflow":"travel_order_lifecycle"}`
}
