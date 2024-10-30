
Feature:  Login Features 
  User Login 
  

Scenario: Succesfull Login
    Given I am User "admin@example.com" 
    And I am a regular user
    And I am an admin user
    When I login with "admin@example.com" , "password"
    Then I should be on the dashboard

Scenario: UnSuccesfull Login
    Given I am User "admin@example.com" 
    And I am a regular user
    And I am an admin user
    When I login with "admin@example.com" , "badpassword"
    Then I should be on the login page
    And I should see error "Bad Email.."



