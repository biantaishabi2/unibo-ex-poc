Feature: TrainOffer CRUD operations
  As a user
  I want to manage train_offer records
  So that I can 火车票可售 offer，承载车次、席别、候补和退改规则快照

  Scenario: Create a new TrainOffer
    When I create a TrainOffer
    Then I should see the TrainOffer

  Scenario: Update an existing TrainOffer
    Given I create a TrainOffer
    When I update the TrainOffer
    Then I should see the TrainOffer

  Scenario: Delete an existing TrainOffer
    Given I create a TrainOffer
    When I delete the TrainOffer
