Feature: VacationOffer CRUD operations
  As a user
  I want to manage vacation_offer records
  So that I can 度假可售 offer，承载套餐、出发日期和预订规则快照

  Scenario: Create a new VacationOffer
    When I create a VacationOffer
    Then I should see the VacationOffer

  Scenario: Update an existing VacationOffer
    Given I create a VacationOffer
    When I update the VacationOffer
    Then I should see the VacationOffer

  Scenario: Delete an existing VacationOffer
    Given I create a VacationOffer
    When I delete the VacationOffer
