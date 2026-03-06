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

// TrainOffer BDD step definitions

var createdTrainOffer *ent.TrainOffer
var testTrainOfferClient *ent.Client

func iCreateATrainOffer(ctx context.Context) error {
	var err error
	createdTrainOffer, err = testTrainOfferClient.TrainOffer.Create().
			SetTenantID(uuid.New()).
			SetHostShopID(uuid.New()).
			SetSupplierCode("test").
			SetTrainNo("test").
			SetDepartureStationCode("test").
			SetDepartureStationName("test").
			SetArrivalStationCode("test").
			SetArrivalStationName("test").
			SetTravelDate(time.Now()).
			SetDepartureAt(time.Now()).
			SetArrivalAt(time.Now()).
			SetSeatClass("test").
			SetSeatCode("test").
			SetIsNoSeat(false).
			SetInventoryStatus("default").
			SetWaitlistSupported(false).
			SetListedPrice(1.0).
			SetSettlementPrice(1.0).
			SetCurrency("test").
			SetBookingRulesSnapshot("test").
			SetChangeRulesSnapshot("test").
			SetRefundRulesSnapshot("test").
			SetSaleStatus("default").
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create train_offer: %w", err)
	}
	return nil
}

func iShouldSeeTheTrainOffer(ctx context.Context) error {
	found, err := testTrainOfferClient.TrainOffer.Get(ctx, createdTrainOffer.ID)
	if err != nil {
		return fmt.Errorf("failed to query train_offer: %w", err)
	}
	if found == nil {
		return fmt.Errorf("train_offer not found")
	}
	return nil
}

func iUpdateTheTrainOffer(ctx context.Context) error {
	_, err := testTrainOfferClient.TrainOffer.UpdateOne(createdTrainOffer).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update train_offer: %w", err)
	}
	return nil
}

func iDeleteTheTrainOffer(ctx context.Context) error {
	err := testTrainOfferClient.TrainOffer.DeleteOne(createdTrainOffer).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete train_offer: %w", err)
	}
	return nil
}

func InitializeScenarioTrainOffer(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a TrainOffer$`, iCreateATrainOffer)
	ctx.Step(`^I should see the TrainOffer$`, iShouldSeeTheTrainOffer)
	ctx.Step(`^I update the TrainOffer$`, iUpdateTheTrainOffer)
	ctx.Step(`^I delete the TrainOffer$`, iDeleteTheTrainOffer)
}

func TestFeaturesTrainOffer(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioTrainOffer,
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
