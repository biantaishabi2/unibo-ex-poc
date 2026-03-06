Feature: TravelOrder CRUD operations
  As a user
  I want to manage travel_order records
  So that I can 统一酒旅订单，承接 hotel、flight、vacation、train 四类商品的下单和状态流转；通过跨域引用关联 Sales::Customer 和 Payment::Payment

  Scenario: Create a new TravelOrder
    When I create a TravelOrder
    Then I should see the TravelOrder

  Scenario: Update an existing TravelOrder
    Given I create a TravelOrder
    When I update the TravelOrder
    Then I should see the TravelOrder

  Scenario: Delete an existing TravelOrder
    Given I create a TravelOrder
    When I delete the TravelOrder
