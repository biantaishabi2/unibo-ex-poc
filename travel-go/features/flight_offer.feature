Feature: FlightOffer CRUD operations
  As a user
  I want to manage flight_offer records
  So that I can 机票可售 offer，承载航班、舱位、票规和库存快照

  Scenario: Create a new FlightOffer
    When I create a FlightOffer
    Then I should see the FlightOffer

  Scenario: Update an existing FlightOffer
    Given I create a FlightOffer
    When I update the FlightOffer
    Then I should see the FlightOffer

  Scenario: Delete an existing FlightOffer
    Given I create a FlightOffer
    When I delete the FlightOffer
