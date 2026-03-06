package hooks

import (
	"context"
	"fmt"

	"entgo.io/ent"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/workflow"
)

// HotelOfferHotelOfferLifecycleHook 在 ent mutation 时验证 HotelOfferLifecycle 状态转换
// fsmFactory 接受当前状态，返回一个初始化好的 FSM 实例
func HotelOfferHotelOfferLifecycleHook(fsmFactory func(string) *workflow.HotelOfferHotelOfferLifecycleFSM) ent.Hook {
	return func(next ent.Mutator) ent.Mutator {
		return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
			if newStatus, exists := m.Field("status"); exists {
				oldStatus, _ := m.OldField(ctx, "status")
				if oldStatus != nil {
					currentState, ok := oldStatus.(string)
					if !ok {
						return nil, fmt.Errorf("HotelOffer: cannot cast current status to string")
					}
					machine := fsmFactory(currentState)
					targetState, ok := newStatus.(string)
					if !ok {
						return nil, fmt.Errorf("HotelOffer: cannot cast new status to string")
					}
					// 查找可用的事件进行转换
					found := false
					for _, t := range machine.FSM.AvailableTransitions() {
						if machine.FSM.Current() != targetState {
							if err := machine.FSM.Event(ctx, t); err == nil {
								if machine.FSM.Current() == targetState {
									found = true
									break
								}
							}
							// 重置状态机重试下一个事件
							machine = fsmFactory(currentState)
						} else {
							found = true
							break
						}
					}
					if !found {
						return nil, fmt.Errorf("HotelOffer: invalid state transition from %s to %s", currentState, targetState)
					}
				}
			}
			return next.Mutate(ctx, m)
		})
	}
}
