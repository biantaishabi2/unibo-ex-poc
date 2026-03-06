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

// TravelOrder holds the schema definition for the TravelOrder entity.
// 统一酒旅订单，承接 hotel、flight、vacation、train 四类商品的下单和状态流转；通过跨域引用关联 Sales::Customer 和 Payment::Payment
type TravelOrder struct {
	ent.Schema
}

// Fields of the TravelOrder.
func (TravelOrder) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.UUID{}).Default(uuid.New),
		field.UUID("tenant_id", uuid.UUID{}),
		field.UUID("host_shop_id", uuid.UUID{}).Optional().Nillable(),
		field.UUID("hotel_offer_id", uuid.UUID{}).Optional().Nillable(),
		field.UUID("flight_offer_id", uuid.UUID{}).Optional().Nillable(),
		field.UUID("vacation_offer_id", uuid.UUID{}).Optional().Nillable(),
		field.UUID("train_offer_id", uuid.UUID{}).Optional().Nillable(),
		field.String("order_no").NotEmpty(),
		field.Enum("product_type").NamedValues("ValHotel", "hotel", "ValFlight", "flight", "ValVacation", "vacation", "ValTrain", "train").Optional().Default("hotel"),
		field.Enum("booking_mode").NamedValues("ValStandard", "standard", "ValWaitlist", "waitlist").Optional().Default("standard"),
		field.UUID("customer_id", uuid.UUID{}),
		field.UUID("payment_id", uuid.UUID{}).Optional().Nillable(),
		field.String("contact_name").NotEmpty(),
		field.String("contact_phone").NotEmpty(),
		field.Int("traveler_count").Optional().Default(1),
		field.Float("total_amount"),
		field.Int("points_to_use").Optional().Default(0),
		field.Float("points_deduction_amount").Optional().Default(0),
		field.String("currency").Optional().Default("CNY"),
		field.Enum("status").NamedValues("ValDraft", "draft", "ValQuoted", "quoted", "ValSubmitted", "submitted", "ValBookingPending", "booking_pending", "ValBooked", "booked", "ValCancelPending", "cancel_pending", "ValCancelled", "cancelled", "ValCompleted", "completed", "ValFailed", "failed").Optional().Default("draft"),
		field.Enum("change_status").NamedValues("ValNone", "none", "ValPending", "pending", "ValChanged", "changed", "ValFailed", "failed").Optional().Default("none"),
		field.Enum("waitlist_status").NamedValues("ValNone", "none", "ValPending", "pending", "ValFulfilled", "fulfilled", "ValCancelled", "cancelled", "ValFailed", "failed").Optional().Default("none"),
		field.String("original_order_ref").Optional(),
		field.String("ticket_passenger_infos").Optional(),
		field.String("seat_selection_snapshot").Optional(),
		field.String("supplier_order_ref").Optional(),
		field.Time("inserted_at").Default(time.Now).Immutable(),
		field.Time("updated_at").Default(time.Now).UpdateDefault(time.Now),
	}
}

// Edges of the TravelOrder.
func (TravelOrder) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("hotel_offer", HotelOffer.Type).Unique().Field("hotel_offer_id"),
		edge.To("flight_offer", FlightOffer.Type).Unique().Field("flight_offer_id"),
		edge.To("vacation_offer", VacationOffer.Type).Unique().Field("vacation_offer_id"),
		edge.To("train_offer", TrainOffer.Type).Unique().Field("train_offer_id"),
		edge.To("fulfillments", TravelFulfillment.Type),
	}
}


// Hooks of the TravelOrder.
func (TravelOrder) Hooks() []ent.Hook {
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
				if v, ok := m.Field("order_no"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "order_no", Message: "order_no must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("customer_id"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "customer_id", Message: "customer_id must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("contact_name"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "contact_name", Message: "contact_name must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("contact_phone"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "contact_phone", Message: "contact_phone must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("traveler_count"); ok {
					if val, ok := v.(float64); ok && val < 1 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "traveler_count", Message: "traveler_count 至少为 1", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("total_amount"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "total_amount", Message: "total_amount 不能为负数", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("points_to_use"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "points_to_use", Message: "points_to_use 不能为负数", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("points_deduction_amount"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "points_deduction_amount", Message: "points_deduction_amount 不能为负数", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"draft"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 draft 订单可以 confirm_quote", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"quoted"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 quoted 订单可以提交普通购票或候补", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"submitted"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 submitted 订单可以进入支付成功或失败结果", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"booking_pending"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 booking_pending 订单可以完成出票、兑现候补或取消候补", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"booked"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 booked 订单可以完成、取消或改签", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"cancel_pending"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "status", Message: "只有 cancel_pending 订单可以 approve_cancel", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("waitlist_status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"pending"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "waitlist_status", Message: "只有 waitlist_pending 的订单可以兑现或取消候补", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("change_status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"pending"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "change_status", Message: "只有 change_pending 的订单可以 confirm_change", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("original_order_ref"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "original_order_ref", Message: "original_order_ref must be present", Code: "present",
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

// Policy defines the privacy policy of the TravelOrder.
func (TravelOrder) Policy() ent.Policy {
	return privacy.Policy{
		Query: privacy.QueryPolicy{
			FilterTenantRule{},
		},
		Mutation: privacy.MutationPolicy{
			FilterTenantRule{},
		},
	}
}

