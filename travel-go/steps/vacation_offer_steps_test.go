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

// VacationOffer BDD step definitions

var createdVacationOffer *ent.VacationOffer
var testVacationOfferClient *ent.Client

func iCreateAVacationOffer(ctx context.Context) error {
	var err error
	createdVacationOffer, err = testVacationOfferClient.VacationOffer.Create().
			SetTenantID(uuid.New()).
			SetHostShopID(uuid.New()).
			SetSupplierCode("test").
			SetPackageCode("test").
			SetPackageName("test").
			SetPackageType("default").
			SetDepartureCityCode("test").
			SetDestinationCode("test").
			SetStartDate(time.Now()).
			SetEndDate(time.Now()).
			SetListedPrice(1.0).
			SetSettlementPrice(1.0).
			SetCurrency("test").
			SetInventoryCount(1).
			SetBookingRules("test").
			SetCancellationPolicy("test").
			SetSaleStatus("default").
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to create vacation_offer: %w", err)
	}
	return nil
}

func iShouldSeeTheVacationOffer(ctx context.Context) error {
	found, err := testVacationOfferClient.VacationOffer.Get(ctx, createdVacationOffer.ID)
	if err != nil {
		return fmt.Errorf("failed to query vacation_offer: %w", err)
	}
	if found == nil {
		return fmt.Errorf("vacation_offer not found")
	}
	return nil
}

func iUpdateTheVacationOffer(ctx context.Context) error {
	_, err := testVacationOfferClient.VacationOffer.UpdateOne(createdVacationOffer).
			SetTenantID(uuid.New()).
		Save(ctx)
	if err != nil {
		return fmt.Errorf("failed to update vacation_offer: %w", err)
	}
	return nil
}

func iDeleteTheVacationOffer(ctx context.Context) error {
	err := testVacationOfferClient.VacationOffer.DeleteOne(createdVacationOffer).Exec(ctx)
	if err != nil {
		return fmt.Errorf("failed to delete vacation_offer: %w", err)
	}
	return nil
}

func InitializeScenarioVacationOffer(ctx *godog.ScenarioContext) {
	ctx.Step(`^I create a VacationOffer$`, iCreateAVacationOffer)
	ctx.Step(`^I should see the VacationOffer$`, iShouldSeeTheVacationOffer)
	ctx.Step(`^I update the VacationOffer$`, iUpdateTheVacationOffer)
	ctx.Step(`^I delete the VacationOffer$`, iDeleteTheVacationOffer)
}

func TestFeaturesVacationOffer(t *testing.T) {
	suite := godog.TestSuite{
		ScenarioInitializer: InitializeScenarioVacationOffer,
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
