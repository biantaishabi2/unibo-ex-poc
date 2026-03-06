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

// HotelOffer BDD step definitions

var createdHotelOffer *ent.HotelOffer
var testHotelOfferClient *ent.Client

func iCreateAHotelOffer(ctx context.Context) error {
	var err error
	createdHotelOffer, err = testHotelOfferClient.HotelOffer.Create().
			SetTenantID(uuid.New()).
			SetHostShopID(uuid.New()).
			SetSupplierCode("test").
			SetHotelCode("test").
			SetHotelName("test").
			SetCityCode("test").
			SetRoomTypeCode("test").
			SetRatePlanCode("test").
			SetCheckinDate(time.Now()).
			SetCheckoutDate(time.Now()).
			SetListedPrice(1.0).
			SetSettlementPrice(1.0).
			SetCurrency("test").
			SetInventoryCount(1).
			SetCancellationPolicy("test").
			SetGuaranteePolicy("test").
			SetSaleStatus("default").
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create hotel_offer: %w", err)
	}
	return nil
}

func iShouldSeeTheHotelOffer(ctx context.Context) error {
	found, err := testHotelOfferClient.HotelOffer.Get(ctx, createdHotelOffer.ID)
	if err != nil {
		return fmt.Errorf("failed to query hotel_offer: %w", err)
	}
	if found == nil {
		return fmt.Errorf("hotel_offer not found")
	}
	return nil
}

func iUpdateTheHotelOffer(ctx context.Context) error {
	_, err := testHotelOfferClient.HotelOffer.UpdateOne(createdHotelOffer).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update hotel_offer: %w", err)
	}
	return nil
}

func iDeleteTheHotelOffer(ctx context.Context) error {
	err := testHotelOfferClient.HotelOffer.DeleteOne(createdHotelOffer).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete hotel_offer: %w", err)
	}
	return nil
}

func InitializeScenarioHotelOffer(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a HotelOffer$`, iCreateAHotelOffer)
	ctx.Step(`^I should see the HotelOffer$`, iShouldSeeTheHotelOffer)
	ctx.Step(`^I update the HotelOffer$`, iUpdateTheHotelOffer)
	ctx.Step(`^I delete the HotelOffer$`, iDeleteTheHotelOffer)
}

func TestFeaturesHotelOffer(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioHotelOffer,
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
