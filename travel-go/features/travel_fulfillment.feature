Feature: TravelFulfillment CRUD operations
  As a user
  I want to manage travel_fulfillment records
  So that I can 统一酒旅履约聚合，承接预订确认、发券出票、候补兑现、乘车使用和失败结果；可选关联 Delivery::Shipment

  Scenario: Create a new TravelFulfillment
    When I create a TravelFulfillment
    Then I should see the TravelFulfillment

  Scenario: Update an existing TravelFulfillment
    Given I create a TravelFulfillment
    When I update the TravelFulfillment
    Then I should see the TravelFulfillment

  Scenario: Delete an existing TravelFulfillment
    Given I create a TravelFulfillment
    When I delete the TravelFulfillment
