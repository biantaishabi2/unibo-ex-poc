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

// TrainOffer holds the schema definition for the TrainOffer entity.
// 火车票可售 offer，承载车次、席别、候补和退改规则快照
type TrainOffer struct {
	ent.Schema
}

// Fields of the TrainOffer.
func (TrainOffer) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.UUID{}).Default(uuid.New),
		field.UUID("tenant_id", uuid.UUID{}),
		field.UUID("host_shop_id", uuid.UUID{}).Optional(),
		field.String("supplier_code").NotEmpty(),
		field.String("train_no").NotEmpty(),
		field.String("departure_station_code").NotEmpty(),
		field.String("departure_station_name").NotEmpty(),
		field.String("arrival_station_code").NotEmpty(),
		field.String("arrival_station_name").NotEmpty(),
		field.Time("travel_date"),
		field.Time("departure_at"),
		field.Time("arrival_at"),
		field.String("seat_class").NotEmpty(),
		field.String("seat_code").NotEmpty(),
		field.Bool("is_no_seat").Optional().Default(false),
		field.Enum("inventory_status").NamedValues("ValAvailable", "available", "ValWaitlistOnly", "waitlist_only", "ValSoldOut", "sold_out", "ValUnavailable", "unavailable").Optional().Default("unavailable"),
		field.Bool("waitlist_supported").Optional().Default(false),
		field.Float("listed_price"),
		field.Float("settlement_price").Optional(),
		field.String("currency").Optional().Default("CNY"),
		field.Text("booking_rules_snapshot").Optional(),
		field.Text("change_rules_snapshot").Optional(),
		field.Text("refund_rules_snapshot").Optional(),
		field.Enum("sale_status").NamedValues("ValDraft", "draft", "ValActive", "active", "ValInactive", "inactive", "ValExpired", "expired").Optional().Default("draft"),
		field.Time("inserted_at").Default(time.Now).Immutable(),
		field.Time("updated_at").Default(time.Now).UpdateDefault(time.Now),
	}
}

// Edges of the TrainOffer.
func (TrainOffer) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("orders", TravelOrder.Type).Ref("train_offer"),
	}
}


// Hooks of the TrainOffer.
func (TrainOffer) Hooks() []ent.Hook {
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
				if v, ok := m.Field("supplier_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "supplier_code", Message: "supplier_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("train_no"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "train_no", Message: "train_no must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("departure_station_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "departure_station_code", Message: "departure_station_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("arrival_station_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "arrival_station_code", Message: "arrival_station_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("seat_class"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "seat_class", Message: "seat_class must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("seat_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "seat_code", Message: "seat_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("listed_price"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "listed_price", Message: "listed_price 不能为负数", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("settlement_price"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "settlement_price", Message: "settlement_price 不能为负数", Code: "compare",
						})
					}
				}
				if v, ok := m.Field("sale_status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"draft", "inactive"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "sale_status", Message: "只有草稿或停用中的 offer 可以 activate", Code: "inclusion",
						})
					}
				}
				if v, ok := m.Field("sale_status"); ok {
					if val, ok := v.(string); ok && !slices.Contains([]string{"active"}, val) {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "sale_status", Message: "只有 active 状态的 offer 可以 deactivate 或 expire", Code: "inclusion",
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

// Policy defines the privacy policy of the TrainOffer.
func (TrainOffer) Policy() ent.Policy {
	return privacy.Policy{
		Query: privacy.QueryPolicy{
			FilterTenantRule{},
		},
		Mutation: privacy.MutationPolicy{
			FilterTenantRule{},
		},
	}
}

