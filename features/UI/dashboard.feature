
Feature:  Dashboard Features
  -- Added fields 
  -- ADMIN Vs User 
  

Scenario: Customer logged in to dashboard
    Given I am User "admin@example.com" 
    And   I am an admin user
    When  I login with "admin@example.com" , "password123!"
    And   I visit "/admin/dashboard" url

Scenario: Admin logged in to dashboard
    Given I am User "admin@example.com" 
    And   I am an admin user
    When  I login with "admin@example.com" , "password123!"
    And   I visit "/admin/dashboard" url
    Then  I should see the total line



Scenario: Test Page
   Given I visit "/admin/login" url
   Then I should be on page "login"

