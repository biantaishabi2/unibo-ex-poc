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

// FlightOffer holds the schema definition for the FlightOffer entity.
// 机票可售 offer，承载航班、舱位、票规和库存快照
type FlightOffer struct {
	ent.Schema
}

// Fields of the FlightOffer.
func (FlightOffer) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.UUID{}).Default(uuid.New),
		field.UUID("tenant_id", uuid.UUID{}),
		field.UUID("host_shop_id", uuid.UUID{}).Optional(),
		field.String("supplier_code").NotEmpty(),
		field.String("itinerary_code").NotEmpty(),
		field.String("flight_no").NotEmpty(),
		field.String("departure_airport_code").NotEmpty(),
		field.String("arrival_airport_code").NotEmpty(),
		field.Time("departure_at"),
		field.Time("arrival_at"),
		field.String("cabin_class").NotEmpty(),
		field.String("fare_family").Optional(),
		field.Float("listed_price"),
		field.Float("settlement_price").Optional(),
		field.String("currency").Optional().Default("CNY"),
		field.Int("seats_available").Optional().Default(0),
		field.Text("baggage_policy").Optional(),
		field.Text("refund_change_policy").Optional(),
		field.Enum("sale_status").NamedValues("ValDraft", "draft", "ValActive", "active", "ValInactive", "inactive", "ValExpired", "expired").Optional().Default("draft"),
		field.Time("inserted_at").Default(time.Now).Immutable(),
		field.Time("updated_at").Default(time.Now).UpdateDefault(time.Now),
	}
}

// Edges of the FlightOffer.
func (FlightOffer) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("orders", TravelOrder.Type).Ref("flight_offer"),
	}
}


// Hooks of the FlightOffer.
func (FlightOffer) Hooks() []ent.Hook {
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
				if v, ok := m.Field("itinerary_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "itinerary_code", Message: "itinerary_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("flight_no"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "flight_no", Message: "flight_no must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("departure_airport_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "departure_airport_code", Message: "departure_airport_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("arrival_airport_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "arrival_airport_code", Message: "arrival_airport_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("cabin_class"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "cabin_class", Message: "cabin_class must be present", Code: "present",
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
				if v, ok := m.Field("seats_available"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "seats_available", Message: "seats_available 不能为负数", Code: "compare",
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

// Policy defines the privacy policy of the FlightOffer.
func (FlightOffer) Policy() ent.Policy {
	return privacy.Policy{
		Query: privacy.QueryPolicy{
			FilterTenantRule{},
		},
		Mutation: privacy.MutationPolicy{
			FilterTenantRule{},
		},
	}
}

