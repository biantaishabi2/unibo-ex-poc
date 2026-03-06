package schema

import (
	"entgo.io/ent"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/edge"
	"context"
	"entgo.io/ent/privacy"
	"github.com/google/uuid"
	"time"
	"slices"
	"github.com/biantaishabi2/unibo-ex-poc/travel-go/internal/validation"
)

// TravelFulfillment holds the schema definition for the TravelFulfillment entity.
// 统一酒旅履约聚合，承接预订确认、发券出票、候补兑现、乘车使用和失败结果；可选关联 Delivery::Shipment
type TravelFulfillment struct {
	ent.Schema
}

// Fields of the TravelFulfillment.
func (TravelFulfillment) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.UUID{}).Default(uuid.New),
		field.UUID("tenant_id", uuid.UUID{}),
		field.UUID("travel_order_id", uuid.UUID{}),
		field.UUID("shipment_id", uuid.UUID{}).Optional(),
		field.Enum("fulfillment_type").NamedValues("ValReserveRoom", "reserve_room", "ValIssueTicket", "issue_ticket", "ValIssueVoucher", "issue_voucher", "ValIssueTrainTicket", "issue_train_ticket").Optional().Default("reserve_room"),
		field.Enum("status").NamedValues("ValPending", "pending", "ValConfirmed", "confirmed", "ValIssued", "issued", "ValInUse", "in_use", "ValCompleted", "completed", "ValCancelled", "cancelled", "ValFailed", "failed").Optional().Default("pending"),
		field.String("supplier_booking_ref").Optional(),
		field.String("voucher_or_ticket_ref").Optional(),
		field.String("ticket_refs").Optional(),
		field.Enum("waitlist_result").NamedValues("ValNone", "none", "ValPending", "pending", "ValFulfilled", "fulfilled", "ValCancelled", "cancelled", "ValFailed", "failed").Optional().Default("none"),
		field.Enum("change_result").NamedValues("ValNone", "none", "ValPending", "pending", "ValChanged", "changed", "ValFailed", "failed").Optional().Default("none"),
		field.Enum("boarding_status").NamedValues("ValNotStarted", "not_started", "ValBoarded", "boarded", "ValCompleted", "completed").Optional().Default("not_started"),
		field.Text("confirmation_payload").Optional(),
		field.Text("failure_reason").Optional(),
		field.Time("used_at").Optional(),
		field.Time("inserted_at").Default(time.Now).Immutable(),
		field.Time("updated_at").Default(time.Now).UpdateDefault(time.Now),
	}
}

// Edges of the TravelFulfillment.
func (TravelFulfillment) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("order", TravelOrder.Type).Ref("fulfillments").Unique().Required().Field("travel_order_id"),
	}
}


// Hooks of the TravelFulfillment.
func (TravelFulfillment) Hooks() []ent.Hook {
	return []ent.Hook{
		func(next ent.Mutator) ent.Mutator {
			return ent.MutateFunc(func(ctx context.Context, m ent.Mutation) (ent.Value, error) {
				if m.Op().Is(ent.OpCreate | ent.OpUpdate) {
					var validationErrors validation.ValidationErrors
				if v, ok := m.Field("tenant_id"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "tenant_id", Message: "tenant_id must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("travel_order_id"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "travel_order_id", Message: "travel_order_id must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"pending"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 pending 履约可以确认、失败或取消", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"confirmed"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 confirmed 履约可以 issue_voucher_or_ticket", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"issued"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 issued 履约可以 mark_in_use", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"issued", "in_use"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 issued 或 in_use 履约可以 complete_fulfillment", Code: "inclusion",
						})
					}
				}
					if validationErrors.HasErrors() {
						return nil, validationErrors
					}
				}
				return next.Mutate(ctx, m)
			})
		},
	}
}

// Policy defines the privacy policy of the TravelFulfillment.
func (TravelFulfillment) Policy() ent.Policy {
	return privacy.Policy{
		Query: privacy.QueryPolicy{
			FilterTenantRule{},
		},
		Mutation: privacy.MutationPolicy{
			FilterTenantRule{},
		},
	}
}

