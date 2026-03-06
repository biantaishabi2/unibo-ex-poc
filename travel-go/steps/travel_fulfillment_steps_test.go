package steps

import (
	"context"
	"fmt"
	"testing"

	"github.com/cucumber/godog"

	"time"
	"github.com/google/uuid"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// TravelFulfillment BDD step definitions

var createdTravelFulfillment *ent.TravelFulfillment
var testTravelFulfillmentClient *ent.Client

func iCreateATravelFulfillment(ctx context.Context) error {
	var err error
	createdTravelFulfillment, err = testTravelFulfillmentClient.TravelFulfillment.Create().
			SetTenantID(uuid.New()).
			SetTravelOrderID(uuid.New()).
			SetShipmentID(uuid.New()).
			SetFulfillmentType("default").
			SetStatus("default").
			SetSupplierBookingRef("test").
			SetVoucherOrTicketRef("test").
			SetTicketRefs("test").
			SetWaitlistResult("default").
			SetChangeResult("default").
			SetBoardingStatus("default").
			SetConfirmationPayload("test").
			SetFailureReason("test").
			SetUsedAt(time.Now()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create travel_fulfillment: %w", err)
	}
	return nil
}

func iShouldSeeTheTravelFulfillment(ctx context.Context) error {
	found, err := testTravelFulfillmentClient.TravelFulfillment.Get(ctx, createdTravelFulfillment.ID)
	if err != nil {
		return fmt.Errorf("failed to query travel_fulfillment: %w", err)
	}
	if found == nil {
		return fmt.Errorf("travel_fulfillment not found")
	}
	return nil
}

func iUpdateTheTravelFulfillment(ctx context.Context) error {
	_, err := testTravelFulfillmentClient.TravelFulfillment.UpdateOne(createdTravelFulfillment).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update travel_fulfillment: %w", err)
	}
	return nil
}

func iDeleteTheTravelFulfillment(ctx context.Context) error {
	err := testTravelFulfillmentClient.TravelFulfillment.DeleteOne(createdTravelFulfillment).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete travel_fulfillment: %w", err)
	}
	return nil
}

func InitializeScenarioTravelFulfillment(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a TravelFulfillment$`, iCreateATravelFulfillment)
	ctx.Step(`^I should see the TravelFulfillment$`, iShouldSeeTheTravelFulfillment)
	ctx.Step(`^I update the TravelFulfillment$`, iUpdateTheTravelFulfillment)
	ctx.Step(`^I delete the TravelFulfillment$`, iDeleteTheTravelFulfillment)
}

func TestFeaturesTravelFulfillment(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioTravelFulfillment,
		Options: &godog.Options{
			Format:   "pretty",
			Paths:    []string{"../features"},
			TestingT: t,
		},
	}

	if suite.Run() != 0 {
		t.Fatal("non-zero status returned, failed to run feature tests")
	}
}
