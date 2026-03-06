package workflow

import (
	"context"

	"github.com/looplab/fsm"
)

// VacationOfferVacationOfferLifecycleFSM 管理 VacationOffer 实体的 VacationOfferLifecycle 状态转换
// 度假 offer 生命周期
// ```mermaid
// stateDiagram-v2
//   [*] --> create
//   create --> update: create_to_update
//   create --> activate: create_to_activate
//   create --> destroy: create_to_destroy
//   update --> activate: update_to_activate
//   update --> destroy: update_to_destroy
//   activate --> deactivate: activate_to_deactivate
//   activate --> expire: activate_to_expire
//   deactivate --> activate: deactivate_to_activate
//   expire --> destroy: expire_to_destroy
//   destroy --> [*]
// ```
type VacationOfferVacationOfferLifecycleFSM struct {
	FSM *fsm.FSM
}

// NewVacationOfferVacationOfferLifecycleFSM 创建新的 VacationOfferLifecycle 状态机实例
func NewVacationOfferVacationOfferLifecycleFSM(initialState string) *VacationOfferVacationOfferLifecycleFSM {
	o := &VacationOfferVacationOfferLifecycleFSM{}
	o.FSM = fsm.NewFSM(
		initialState,
		fsm.Events{
			{Name: "create_to_update", Src: []string{"create"}, Dst: "update"},
			{Name: "create_to_activate", Src: []string{"create"}, Dst: "activate"},
			{Name: "create_to_destroy", Src: []string{"create"}, Dst: "destroy"},
			{Name: "update_to_activate", Src: []string{"update"}, Dst: "activate"},
			{Name: "update_to_destroy", Src: []string{"update"}, Dst: "destroy"},
			{Name: "activate_to_deactivate", Src: []string{"activate"}, Dst: "deactivate"},
			{Name: "activate_to_expire", Src: []string{"activate"}, Dst: "expire"},
			{Name: "deactivate_to_activate", Src: []string{"deactivate"}, Dst: "activate"},
			{Name: "expire_to_destroy", Src: []string{"expire"}, Dst: "destroy"},
		},
		fsm.Callbacks{
			"enter_activate": func(_ context.Context, e *fsm.Event) {
				// 触发事件: activated
			},
			"enter_deactivate": func(_ context.Context, e *fsm.Event) {
				// 触发事件: deactivated
			},
			"enter_expire": func(_ context.Context, e *fsm.Event) {
				// 触发事件: expired
			},
		},
	)
	return o
}

// DefaultInitialState 返回 VacationOfferLifecycle 的默认初始状态
func VacationOfferVacationOfferLifecycleFSMDefaultInitialState() string {
	return "create"
}

// VacationOfferVacationOfferLifecycleFSMWorkflowSemanticsJSON 返回编排语义快照（供跨端回放比对）
func VacationOfferVacationOfferLifecycleFSMWorkflowSemanticsJSON() string {
	return `{"steps":[{"idempotency_key":null,"next":["update","activate","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"create"},{"idempotency_key":null,"next":["activate","destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"update"},{"idempotency_key":null,"next":["deactivate","expire"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"activate"},{"idempotency_key":null,"next":["activate"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"deactivate"},{"idempotency_key":null,"next":["destroy"],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"expire"},{"idempotency_key":null,"next":[],"on_error":[],"retry":{"backoff_ms":0,"max_attempts":1},"step":"destroy"}],"workflow":"vacation_offer_lifecycle"}`
}
