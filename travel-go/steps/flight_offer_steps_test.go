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

// FlightOffer BDD step definitions

var createdFlightOffer *ent.FlightOffer
var testFlightOfferClient *ent.Client

func iCreateAFlightOffer(ctx context.Context) error {
	var err error
	createdFlightOffer, err = testFlightOfferClient.FlightOffer.Create().
			SetTenantID(uuid.New()).
			SetHostShopID(uuid.New()).
			SetSupplierCode("test").
			SetItineraryCode("test").
			SetFlightNo("test").
			SetDepartureAirportCode("test").
			SetArrivalAirportCode("test").
			SetDepartureAt(time.Now()).
			SetArrivalAt(time.Now()).
			SetCabinClass("test").
			SetFareFamily("test").
			SetListedPrice(1.0).
			SetSettlementPrice(1.0).
			SetCurrency("test").
			SetSeatsAvailable(1).
			SetBaggagePolicy("test").
			SetRefundChangePolicy("test").
			SetSaleStatus("default").
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create flight_offer: %w", err)
	}
	return nil
}

func iShouldSeeTheFlightOffer(ctx context.Context) error {
	found, err := testFlightOfferClient.FlightOffer.Get(ctx, createdFlightOffer.ID)
	if err != nil {
		return fmt.Errorf("failed to query flight_offer: %w", err)
	}
	if found == nil {
		return fmt.Errorf("flight_offer not found")
	}
	return nil
}

func iUpdateTheFlightOffer(ctx context.Context) error {
	_, err := testFlightOfferClient.FlightOffer.UpdateOne(createdFlightOffer).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update flight_offer: %w", err)
	}
	return nil
}

func iDeleteTheFlightOffer(ctx context.Context) error {
	err := testFlightOfferClient.FlightOffer.DeleteOne(createdFlightOffer).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete flight_offer: %w", err)
	}
	return nil
}

func InitializeScenarioFlightOffer(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a FlightOffer$`, iCreateAFlightOffer)
	ctx.Step(`^I should see the FlightOffer$`, iShouldSeeTheFlightOffer)
	ctx.Step(`^I update the FlightOffer$`, iUpdateTheFlightOffer)
	ctx.Step(`^I delete the FlightOffer$`, iDeleteTheFlightOffer)
}

func TestFeaturesFlightOffer(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioFlightOffer,
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
