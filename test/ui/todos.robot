*** Settings ***
Library         SeleniumLibrary
Resource        setup_teardown.resource
Suite Setup     Prepare the test suite
Test Setup      Prepare the test case
Test Teardown   Clean up the test case
Suite Teardown  Clean up the test suite

*** Variables ***
&{CATEGORIES}
...             private=Personnel
...             professional=Professionnel
...             all=Tout

*** Test Cases ***
I can add a todo
  When I submit a todo Adopter de bonnes pratiques de test
  Then a new todo #1 should be created being Adopter de bonnes pratiques de test

I can complete one of several todos
  Given an existing todo #1 being Adopter de bonnes pratiques de test
  And an existing todo #2 being Comprendre le Keyword-Driven Testing
  And an existing todo #3 being Automatiser des cas de test avec Robot Framework
  When I complete the todo #2
  Then the todo #2 should be completed
  And the todo #1 should be uncompleted
  And the todo #3 should be uncompleted

I can remove a todo
  Given an existing todo #1 being Choisir le bon type de framework de test
  When I remove a todo #1
  Then the todo #1 should be deleted

I can categorize some todos
  When I submit a todo Choisir un livre intéressant
  Then the todo #1 should not be categorized
  When I submit a private todo Marcher et faire du vélo avec mon chien
  Then the todo #2 should be private
  When I submit a todo Faire un câlin avec mon chat
  Then the todo #3 should be private
  When I submit a professional todo Automatiser un cas de test de plus
  Then the todo #4 should be professional

I can read only one category of todos
  Given an existing todo #1 being Écrire un livre
  And an existing professional todo #2 being Réaliser un spike de test
  And an existing private todo #3 being Tapisser le mur du salon
  And an existing professional todo #4 being Évaluer un framework de développement de test
  Given I must see 4 todos
  When I check the private category
  Then I should see 1 private todos
  When I check the professional category
  Then I should see 2 professional todos
  When I check all categories
  Then I should see 4 todos

*** Keywords ***
I submit a todo ${description:[^\n]+}
  Submit a todo  ${description}

I submit a ${category:(private|professional)} todo ${description:[^\n]+}
  Submit a todo  ${description}  ${CATEGORIES.${category}}

Submit a todo
  [Arguments]  ${description}  ${category}=${None}
  Run keyword unless  '${category}' == '${None}'
  ...  Select from list by value  data-id:select.category  ${category}
  Input text  data-id:input.text.description  ${description}
  Submit form

a new todo #${number:\d+} should be created being ${description:[^\n]+}
  Element should contain  todo:${number}  ${description}
  Checkbox should not be selected  data-id:input.checkbox.done-${number}

an existing todo #${number:\d+} being ${description:[^\n]+}
  Submit a todo  ${description}
  A new todo #${number} should be created being ${description}

an existing ${category:(private|professional)} todo #${number:\d+} being ${description:[^\n]+}
  Submit a todo  ${description}  ${CATEGORIES.${category}}
  A new todo #${number} should be created being ${description}

I complete the todo #${number:\d+}
  Select checkbox  data-id:input.checkbox.done-${number}

the todo #${number:\d+} should be completed
  Checkbox should be selected  data-id:input.checkbox.done-${number}

the todo #${number:\d+} should be uncompleted
  Checkbox should not be selected  data-id:input.checkbox.done-${number}

I remove a todo #${number:\d+}
  Page should contain button  data-id:button.remove_todo-${number}
  Click button  data-id:button.remove_todo-${number}

the todo #${number:\d+} should be deleted
  Page should not contain element  todo:${number}

The todo #${number:\d+} should not be categorized
  Page should not contain element  data-id:text.todo_category-${number}

the todo #${number:\d+} should be ${category:(private|professional)}
  Element text should be  data-id:text.todo_category-${number}  ${CATEGORIES.${category}}

I must see ${number:\d+} todos
  Should see todos  ${number}

I should see ${number:\d+} todos
  Should see todos  ${number}

I should see ${number:\d+} ${category:(private|professional)} todos
  Should see todos  ${number}  ${CATEGORIES.${category}}

Should see todos
  [Arguments]  ${expected_number_of_todos}  ${expected_category}=${CATEGORIES.all}
  ${actual_number_of_todos} =  Get element count  //*[@data-id[starts-with(., "todo-")]]
  Should be equal as integers  ${actual_number_of_todos}  ${expected_number_of_todos}  Unexpected number of visible todos
  IF  '${expected_category}' != '${CATEGORIES.all}'
    ${actual_number_of_todos} =  Get element count  //*[@data-id[starts-with(., "todo-")] and ./*[starts-with(@data-id, "text.todo_category-") and text()="${expected_category}"]]
    Should be equal as integers  ${actual_number_of_todos}  ${expected_number_of_todos}  Unexpected number of todos in '${expected_category}'
  END

I check the ${category_to_display:(private|professional)} category
  Check a category  ${CATEGORIES.${category_to_display}}

I check all categories
  Check a category  ${CATEGORIES.all}

Check a category
  [Arguments]  ${category_to_display}
  Select radio button  category_to_display  ${category_to_display}
