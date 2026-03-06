package testutil

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/biantaishabi2/unibo-ex-poc/travel-go/ent"
)

// CreateFlightOffer 创建一个默认的 FlightOffer 实例（用于测试）
func CreateFlightOffer(ctx context.Context, client *ent.Client) *ent.FlightOffer {
	entity, err := client.FlightOffer.Create().
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
		SetSaleStatus("draft").
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create FlightOffer: %v", err))
	}
	return entity
}

// CreateHotelOffer 创建一个默认的 HotelOffer 实例（用于测试）
func CreateHotelOffer(ctx context.Context, client *ent.Client) *ent.HotelOffer {
	entity, err := client.HotelOffer.Create().
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
		SetSaleStatus("draft").
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create HotelOffer: %v", err))
	}
	return entity
}

// CreateTrainOffer 创建一个默认的 TrainOffer 实例（用于测试）
func CreateTrainOffer(ctx context.Context, client *ent.Client) *ent.TrainOffer {
	entity, err := client.TrainOffer.Create().
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
		SetInventoryStatus("available").
		SetWaitlistSupported(false).
		SetListedPrice(1.0).
		SetSettlementPrice(1.0).
		SetCurrency("test").
		SetBookingRulesSnapshot("test").
		SetChangeRulesSnapshot("test").
		SetRefundRulesSnapshot("test").
		SetSaleStatus("draft").
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create TrainOffer: %v", err))
	}
	return entity
}

// CreateTravelFulfillment 创建一个默认的 TravelFulfillment 实例（用于测试）
func CreateTravelFulfillment(ctx context.Context, client *ent.Client) *ent.TravelFulfillment {
	entity, err := client.TravelFulfillment.Create().
		SetTenantID(uuid.New()).
		SetTravelOrderID(uuid.New()).
		SetNillableShipmentID(&uuid.UUID{}).
		SetFulfillmentType("reserve_room").
		SetStatus("pending").
		SetSupplierBookingRef("test").
		SetVoucherOrTicketRef("test").
		SetTicketRefs("test").
		SetWaitlistResult("none").
		SetChangeResult("none").
		SetBoardingStatus("not_started").
		SetConfirmationPayload("test").
		SetFailureReason("test").
		SetUsedAt(time.Now()).
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create TravelFulfillment: %v", err))
	}
	return entity
}

// CreateTravelOrder 创建一个默认的 TravelOrder 实例（用于测试）
func CreateTravelOrder(ctx context.Context, client *ent.Client) *ent.TravelOrder {
	entity, err := client.TravelOrder.Create().
		SetTenantID(uuid.New()).
		SetNillableHostShopID(&uuid.UUID{}).
		SetNillableHotelOfferID(&uuid.UUID{}).
		SetNillableFlightOfferID(&uuid.UUID{}).
		SetNillableVacationOfferID(&uuid.UUID{}).
		SetNillableTrainOfferID(&uuid.UUID{}).
		SetOrderNo("test").
		SetProductType("hotel").
		SetBookingMode("standard").
		SetCustomerID(uuid.New()).
		SetNillablePaymentID(&uuid.UUID{}).
		SetContactName("test").
		SetContactPhone("test").
		SetTravelerCount(1).
		SetTotalAmount(1.0).
		SetPointsToUse(1).
		SetPointsDeductionAmount(1.0).
		SetCurrency("test").
		SetStatus("draft").
		SetChangeStatus("none").
		SetWaitlistStatus("none").
		SetOriginalOrderRef("test").
		SetTicketPassengerInfos("test").
		SetSeatSelectionSnapshot("test").
		SetSupplierOrderRef("test").
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create TravelOrder: %v", err))
	}
	return entity
}

// CreateVacationOffer 创建一个默认的 VacationOffer 实例（用于测试）
func CreateVacationOffer(ctx context.Context, client *ent.Client) *ent.VacationOffer {
	entity, err := client.VacationOffer.Create().
		SetTenantID(uuid.New()).
		SetHostShopID(uuid.New()).
		SetSupplierCode("test").
		SetPackageCode("test").
		SetPackageName("test").
		SetPackageType("group_tour").
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
		SetSaleStatus("draft").
		Save(ctx)
	if err != nil {
		panic(fmt.Sprintf("failed to create VacationOffer: %v", err))
	}
	return entity
}
