*** Settings ***
Library         SeleniumLibrary

*** Keywords ***
Prepare the test suite
  Open browser  url=http://localhost:9090  browser=chrome
  Set window size  width=600  height=300  inner=true
  Set selenium timeout  10 seconds
  ${selenium_speed} =  Get variable value  ${SPEED}  0
  Set selenium speed  ${selenium speed} seconds
  Add location strategy  strategy_name=data-id  strategy_keyword=test id locator strategy
  Add location strategy  strategy_name=todo  strategy_keyword=todo locator strategy

Test id locator strategy
  [Arguments]  ${browser}  ${locator}  ${tag}  ${constraints}
  ${element}=  Execute javascript  return window.document.querySelector('[data-id="${locator}"]');
  [Return]  ${element}

Todo locator strategy
  [Arguments]  ${browser}  ${locator}  ${tag}  ${constraints}
  ${element}=  Execute javascript  return window.document.querySelector('ul > li[data-id="todo-${locator}"]');
  [Return]  ${element}

Prepare the test case
  Wait until page contains element  id:heading
  Title should be  Tout Doux

Clean up the test case
  Reload page

Clean up the test suite
  Close all browsers
