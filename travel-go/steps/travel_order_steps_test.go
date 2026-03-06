package steps

import (
	"context"
	"fmt"
	"testing"

	"github.com/cucumber/godog"

	"github.com/google/uuid"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// TravelOrder BDD step definitions

var createdTravelOrder *ent.TravelOrder
var testTravelOrderClient *ent.Client

func iCreateATravelOrder(ctx context.Context) error {
	var err error
	createdTravelOrder, err = testTravelOrderClient.TravelOrder.Create().
			SetTenantID(uuid.New()).
			SetHostShopID(uuid.New()).
			SetHotelOfferID(uuid.New()).
			SetFlightOfferID(uuid.New()).
			SetVacationOfferID(uuid.New()).
			SetTrainOfferID(uuid.New()).
			SetOrderNo("test").
			SetProductType("default").
			SetBookingMode("default").
			SetCustomerID(uuid.New()).
			SetPaymentID(uuid.New()).
			SetContactName("test").
			SetContactPhone("test").
			SetTravelerCount(1).
			SetTotalAmount(1.0).
			SetPointsToUse(1).
			SetPointsDeductionAmount(1.0).
			SetCurrency("test").
			SetStatus("default").
			SetChangeStatus("default").
			SetWaitlistStatus("default").
			SetOriginalOrderRef("test").
			SetTicketPassengerInfos("test").
			SetSeatSelectionSnapshot("test").
			SetSupplierOrderRef("test").
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create travel_order: %w", err)
	}
	return nil
}

func iShouldSeeTheTravelOrder(ctx context.Context) error {
	found, err := testTravelOrderClient.TravelOrder.Get(ctx, createdTravelOrder.ID)
	if err != nil {
		return fmt.Errorf("failed to query travel_order: %w", err)
	}
	if found == nil {
		return fmt.Errorf("travel_order not found")
	}
	return nil
}

func iUpdateTheTravelOrder(ctx context.Context) error {
	_, err := testTravelOrderClient.TravelOrder.UpdateOne(createdTravelOrder).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update travel_order: %w", err)
	}
	return nil
}

func iDeleteTheTravelOrder(ctx context.Context) error {
	err := testTravelOrderClient.TravelOrder.DeleteOne(createdTravelOrder).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete travel_order: %w", err)
	}
	return nil
}

func InitializeScenarioTravelOrder(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a TravelOrder$`, iCreateATravelOrder)
	ctx.Step(`^I should see the TravelOrder$`, iShouldSeeTheTravelOrder)
	ctx.Step(`^I update the TravelOrder$`, iUpdateTheTravelOrder)
	ctx.Step(`^I delete the TravelOrder$`, iDeleteTheTravelOrder)
}

func TestFeaturesTravelOrder(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioTravelOrder,
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
