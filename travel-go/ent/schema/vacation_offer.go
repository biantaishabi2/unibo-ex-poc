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

// VacationOffer holds the schema definition for the VacationOffer entity.
// 度假可售 offer，承载套餐、出发日期和预订规则快照
type VacationOffer struct {
	ent.Schema
}

// Fields of the VacationOffer.
func (VacationOffer) Fields() []ent.Field {
	return []ent.Field{
		field.UUID("id", uuid.UUID{}).Default(uuid.New),
		field.UUID("tenant_id", uuid.UUID{}),
		field.UUID("host_shop_id", uuid.UUID{}).Optional(),
		field.String("supplier_code").NotEmpty(),
		field.String("package_code").NotEmpty(),
		field.String("package_name").NotEmpty(),
		field.Enum("package_type").NamedValues("ValGroupTour", "group_tour", "ValFreeTravel", "free_travel", "ValTicketHotel", "ticket_hotel", "ValCustom", "custom").Optional().Default("group_tour"),
		field.String("departure_city_code").NotEmpty(),
		field.String("destination_code").NotEmpty(),
		field.Time("start_date"),
		field.Time("end_date"),
		field.Float("listed_price"),
		field.Float("settlement_price").Optional(),
		field.String("currency").Optional().Default("CNY"),
		field.Int("inventory_count").Optional().Default(0),
		field.Text("booking_rules").Optional(),
		field.Text("cancellation_policy").Optional(),
		field.Enum("sale_status").NamedValues("ValDraft", "draft", "ValActive", "active", "ValInactive", "inactive", "ValExpired", "expired").Optional().Default("draft"),
		field.Time("inserted_at").Default(time.Now).Immutable(),
		field.Time("updated_at").Default(time.Now).UpdateDefault(time.Now),
	}
}

// Edges of the VacationOffer.
func (VacationOffer) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("orders", TravelOrder.Type).Ref("vacation_offer"),
	}
}


// Hooks of the VacationOffer.
func (VacationOffer) Hooks() []ent.Hook {
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
				if v, ok := m.Field("package_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "package_code", Message: "package_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("package_name"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "package_name", Message: "package_name must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("departure_city_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "departure_city_code", Message: "departure_city_code must be present", Code: "present",
						})
					}
				}
				if v, ok := m.Field("destination_code"); ok {
					if val, ok := v.(string); ok && val == "" {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "destination_code", Message: "destination_code must be present", Code: "present",
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
				if v, ok := m.Field("inventory_count"); ok {
					if val, ok := v.(float64); ok && val < 0 {
						validationErrors = append(validationErrors, validation.ValidationError{
							Field: "inventory_count", Message: "inventory_count 不能为负数", Code: "compare",
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

// Policy defines the privacy policy of the VacationOffer.
func (VacationOffer) Policy() ent.Policy {
	return privacy.Policy{
		Query: privacy.QueryPolicy{
			FilterTenantRule{},
		},
		Mutation: privacy.MutationPolicy{
			FilterTenantRule{},
		},
	}
}

