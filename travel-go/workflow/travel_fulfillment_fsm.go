package workflow

import (
	"context"

	"github.com/looplab/fsm"
)

// TravelFulfillmentTravelFulfillmentLifecycleFSM 管理 TravelFulfillment 实体的 TravelFulfillmentLifecycle 状态转换
// 统一酒旅履约生命周期
// ```mermaid
// stateDiagram-v2
//   [*] --> create_fulfillment
//   create_fulfillment --> update: create_fulfillment_to_update
//   create_fulfillment --> confirm_booking: create_fulfillment_to_confirm_booking
//   create_fulfillment --> fail_fulfillment: create_fulfillment_to_fail_fulfillment
//   create_fulfillment --> cancel_fulfillment: create_fulfillment_to_cancel_fulfillment
//   create_fulfillment --> destroy: create_fulfillment_to_destroy
//   update --> confirm_booking: update_to_confirm_booking
//   update --> fail_fulfillment: update_to_fail_fulfillment
//   update --> cancel_fulfillment: update_to_cancel_fulfillment
//   update --> destroy: update_to_destroy
//   confirm_booking --> issue_voucher_or_ticket: confirm_booking_to_issue_voucher_or_ticket
//   issue_voucher_or_ticket --> mark_in_use: issue_voucher_or_ticket_to_mark_in_use
//   issue_voucher_or_ticket --> complete_fulfillment: issue_voucher_or_ticket_to_complete_fulfillment
//   mark_in_use --> complete_fulfillment: mark_in_use_to_complete_fulfillment
//   complete_fulfillment --> cancel_fulfillment: complete_fulfillment_to_cancel_fulfillment
//   cancel_fulfillment --> fail_fulfillment: cancel_fulfillment_to_fail_fulfillment
//   fail_fulfillment --> destroy: fail_fulfillment_to_destroy
//   destroy --> [*]
// ```
type TravelFulfillmentTravelFulfillmentLifecycleFSM struct {
	FSM *fsm.FSM
}

// NewTravelFulfillmentTravelFulfillmentLifecycleFSM 创建新的 TravelFulfillmentLifecycle 状态机实例
func NewTravelFulfillmentTravelFulfillmentLifecycleFSM(initialState string) *TravelFulfillmentTravelFulfillmentLifecycleFSM {
	o := &TravelFulfillmentTravelFulfillmentLifecycleFSM{}
	o.FSM = fsm.NewFSM(
		initialState,
		fsm.Events{
			{Name: "create_fulfillment_to_update", Src: []string{"create_fulfillment"}, Dst: "update"},
			{Name: "create_fulfillment_to_confirm_booking", Src: []string{"create_fulfillment"}, Dst: "confirm_booking"},
			{Name: "create_fulfillment_to_fail_fulfillment", Src: []string{"create_fulfillment"}, Dst: "fail_fulfillment"},
			{Name: "create_fulfillment_to_cancel_fulfillment", Src: []string{"create_fulfillment"}, Dst: "cancel_fulfillment"},
			{Name: "create_fulfillment_to_destroy", Src: []string{"create_fulfillment"}, Dst: "destroy"},
			{Name: "update_to_confirm_booking", Src: []string{"update"}, Dst: "confirm_booking"},
			{Name: "update_to_fail_fulfillment", Src: []string{"update"}, Dst: "fail_fulfillment"},
			{Name: "update_to_cancel_fulfillment", Src: []string{"update"}, Dst: "cancel_fulfillment"},
			{Name: "update_to_destroy", Src: []string{"update"}, Dst: "destroy"},
			{Name: "confirm_booking_to_issue_voucher_or_ticket", Src: []string{"confirm_booking"}, Dst: "issue_voucher_or_ticket"},
			{Name: "issue_voucher_or_ticket_to_mark_in_use", Src: []string{"issue_voucher_or_ticket"}, Dst: "mark_in_use"},
			{Name: "issue_voucher_or_ticket_to_complete_fulfillment", Src: []string{"issue_voucher_or_ticket"}, Dst: "complete_fulfillment"},
			{Name: "mark_in_use_to_complete_fulfillment", Src: []string{"mark_in_use"}, Dst: "complete_fulfillment"},
			{Name: "complete_fulfillment_to_cancel_fulfillment", Src: []string{"complete_fulfillment"}, Dst: "cancel_fulfillment"},
			{Name: "cancel_fulfillment_to_fail_fulfillment", Src: []string{"cancel_fulfillment"}, Dst: "fail_fulfillment"},
			{Name: "fail_fulfillment_to_destroy", Src: []string{"fail_fulfillment"}, Dst: "destroy"},
		},
		fsm.Callbacks{
			"enter_confirm_booking": func(_ context.Context, e *fsm.Event) {
				// 触发事件: confirmed
			},
			"enter_issue_voucher_or_ticket": func(_ context.Context, e *fsm.Event) {
				// 触发事件: issued
			},
			"enter_complete_fulfillment": func(_ context.Context, e *fsm.Event) {
				// 触发事件: completed
			},
			"enter_cancel_fulfillment": func(_ context.Context, e *fsm.Event) {
				// 触发事件: cancelled
			},
			"enter_fail_fulfillment": func(_ context.Context, e *fsm.Event) {
				// 触发事件: failed
			},
		},
	)
	return o
}

// DefaultInitialState 返回 TravelFulfillmentLifecycle 的默认初始状态
func TravelFulfillmentTravelFulfillmentLifecycleFSMDefaultInitialState() string {
	return "create_fulfillment"
}

// TravelFulfillmentTravelFulfillmentLifecycleFSMWorkflowSemanticsJSON 返回编排语义快照（供跨端回放比对）
func TravelFulfillmentTravelFulfillmentLifecycleFSMWorkflowSemanticsJSON() string {
	return `{"steps":[{"idempotency_key":null,"next":["update","confirm_booking","fail_fulfillment","cancel_fulfillment","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create_fulfillment"},{"idempotency_key":null,"next":["confirm_booking","fail_fulfillment","cancel_fulfillment","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update"},{"idempotency_key":null,"next":["issue_voucher_or_ticket"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"confirm_booking"},{"idempotency_key":null,"next":["mark_in_use","complete_fulfillment"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"issue_voucher_or_ticket"},{"idempotency_key":null,"next":["complete_fulfillment"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"mark_in_use"},{"idempotency_key":null,"next":["cancel_fulfillment"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"complete_fulfillment"},{"idempotency_key":null,"next":["fail_fulfillment"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"cancel_fulfillment"},{"idempotency_key":null,"next":["destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"fail_fulfillment"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"destroy"}],"workflow":"travel_fulfillment_lifecycle"}`
}
