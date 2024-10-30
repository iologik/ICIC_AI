
Feature:  Payments features
  Export to Quickbooks

Scenario: Export to Quickbooks
    Given I have the following payments:

      | due date   | amount  | user               |
      | Milk       | 2.99    | regular@gmail.com  |
      | Puzzle     | 8.99    | regular@gmail.com  | 


    And I export to quickbooks
    Then  I should have a CSV file
    And   it should have 7 lines 
    And   it should line with "23,234,345,456" 
    And   it should line with "23,234,345,456" 

