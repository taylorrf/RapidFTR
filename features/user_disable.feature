Feature:
  So that only those who should have access are able to access the system,
  an Admin should be able to disable and later re-enable user accounts via the web interface.

  # Scenario: Disabled user can't log in
  #   see user_login.feature

  Scenario: Admin disables a user from the edit page
    Given a user "george"
    And an admin "adam"
    And I have logged in as "adam"
    And I am on edit user page for "george"
    When I check "Disabled?"
    # XXX: re-enter password should go away once user admin is proper
    And I fill in "123" for "Re-enter password"
    And I press "Update"
    Then user "george" should be disabled

  Scenario: Admin re-enables a user from the edit page
    Given a user "george"
    And an admin "adam"
    And user "george" is disabled
    And I have logged in as "adam"
    And I am on edit user page for "george"
    When I uncheck "Disabled?"
    # XXX: re-enter password should go away once user admin is proper
    And I fill in "123" for "Re-enter password"
    And I press "Update"
    Then user "george" should not be disabled

  @allow-rescue
  Scenario: A user who is disabled mid-session can't continue using that session
    Given I am logged in as "george"
    And I am on the children listing page
    When user "george" is disabled
    And I follow "New child"
    Then I should have received a "401 Unauthorized" status code
