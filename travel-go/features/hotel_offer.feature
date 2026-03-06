Feature: HotelOffer CRUD operations
  As a user
  I want to manage hotel_offer records
  So that I can 酒店可售 offer，承载房型、价计划、价态和可售规则快照

  Scenario: Create a new HotelOffer
    When I create a HotelOffer
    Then I should see the HotelOffer

  Scenario: Update an existing HotelOffer
    Given I create a HotelOffer
    When I update the HotelOffer
    Then I should see the HotelOffer

  Scenario: Delete an existing HotelOffer
    Given I create a HotelOffer
    When I delete the HotelOffer
