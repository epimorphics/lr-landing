Feature: HMLR Branding
  As a user
  I want to see consistent HM Land Registry branding
  So that I can identify official government data services

  Scenario: Verify logo on home page
    Given I am a visitor
    When I open the url "/"
    Then I expect the attribute "src" from element "img" contain "hm_lr_logo"

  Scenario: Check banner on Elda page
    Given I am a visitor
    When I open the url "/anything"
    Then I expect the element "nav.site" is on the page
    # TODO: Add style check for background-image containing 'hmg-banner.png'
    # Requires custom step or inline style attribute check
