Feature: Landing Page
  As a user
  I want to access the HM Land Registry Open Data landing page
  So that I can navigate to the various data services

  Scenario: Landing page displays expected content
    Given I am a visitor
    When I open the url "/"
    Then I expect the page title contains "HM Land Registry Open Data"
    And I expect the element "body" contains text "HM Land Registry Open Data"
    And I expect the element "link[rel='stylesheet'][href*='application']" is on the page
    # TODO: Add full validation (that CSS rules exist)
    # Requires custom step doing all three levels of validation:
    # 1. Does a stylesheet with this filename pattern exist? (href match) [current last expectation]
    # 2. Did it load successfully? (cssRules accessible)
    # 3. Does it contain CSS rules? (cssRules.length > 0)
