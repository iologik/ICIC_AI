
Feature:  AMF 
  Sub investments with referal

Scenario: AMF referal with one time fee
    Given I have SubInvestment of $100000 
    And there is a referral 
    And the referral is paid $299 one time on 05/01/2012
    And I create payments
    Then the investment money raised should be $100000
    And the referral should have 1 payment of $299 due to 05/01/2012
    And I should have 1 principle payments

Scenario: AMF referal with monthely payments (percent)
    Given I have SubInvestment of $100000 
    And there is a referral 
    And the referral is paid 12% monthly
    And I create payments
    Then the investment money raised should be $100000
    And the referral should have 13 payments of about $12000
    And I should have 1 principle payments

Scenario: AMF referal with quarterly payments (percent)
    Given I have SubInvestment of $100000 
    And there is a referral 
    And the referral is paid 12% quarterly
    And I create payments
    Then the investment money raised should be $100000
    And the referral should have 5 payments of about $12000
    And I should have 1 principle payments

Scenario: Updateing AMF Payments after withdraw 
    Given I have Investment of $100000
    And I subinvest $2000000 
    And I create payments
    And the investment money raised should be $2000000