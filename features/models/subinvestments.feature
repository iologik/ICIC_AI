
Feature:  investments
  Sub investment calculation
  

Scenario: User invest in project short
    Given I have Investment of $100000
    And I subinvest $200000 
    And I create payments
    Then I should have 0 withdraws
    And I should have 14 payments
    And I should have 13 interest payments
    And I should have 0 AMF payments
    And I should have 1 principle payments
    And the investment money raised should be $200000


Scenario: User invest in project and withdraw 
    Given I have Investment of $2000
    And I subinvest $1000 
    And I create payments
    When I withdraw $100 due on 31/12/2013
    Then I should have 1 withdraws
    And the investment money raised should be $900


Scenario: BUG FIX after withdraw future payments are deleted
    Given I have Investment of $2000
    And I subinvest $1000 
    And I create payments
    Then I should have 14 payments 
    When I withdraw $100 due on 31/12/2013
    Then I should have 1 withdraws
    And I should have 15 payments 
    And the investment money raised should be $900


Scenario: User invest in project monthly
    Given I have Investment of $300000
    And I subinvest $65400
    And the invest is for period of 12 months 
    And the start date  is  2013-01-01   
    And the per_annum rate is 12%
    And the accrued_per_annum rate is 0%
    And I create payments
    Then I should have 13 payments  
    And I should have 0 AMF payments
    And I should have 1 principle payments
    And I should have payment of $654.0  due on  01/02/2013


Scenario: User invest in project monthly and accrude per annum
    Given I have Investment of $300000
    And I subinvest $65400
    And the invest is for period of 12 months 
    And the start date  is  2013-01-01   
    And the per_annum rate is 12%
    And the accrued_per_annum rate is 10%
    And I create payments
    Then I should have 14 payments  
    And I should have 0 AMF payments
    And I should have 1 principle payments
    And I should have payment of $654.0  due on  01/02/2013

  
Scenario: User invest in project Quarterly
    Given I have Investment of $100000
    And I subinvest $2000000 
    And the invest is for period of 8 months 
    And the payment schedule is quarterly
    And the per_annum rate is 12%
    And the accrued_per_annum rate is 12%
    And I create payments
    Then I should have 5 payments 
    And the investment money raised should be $0
    And I should have 0 AMF payments
    And I should have 1 principle payments
    And I should have payment of $200000.0  due on  31/03/2015
    And I should have payment of $60000.0  due on  31/12/2014
    

Scenario: BUGFIX - payments get delete..
    Given I have Investment of $100000
    And I subinvest $200000 
    And I create payments
    And I subinvest $300000
    And I create payments
    Then I should have 12 payments  
