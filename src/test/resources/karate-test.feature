Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    * header Content-Type = 'application/json'

  Scenario: Verificar que un endpoint público responde 200
    Given url 'https://httpbin.org/get'
    When method get
    Then status 200

  @id:1 @obtenerPersonajes
  Scenario: Obtener todos los personajes
    Given path 'characters'
    When method GET
    Then status 200
    And match response == '#[]'
    And match each response == { id: '#number', name: '#string', alterego: '#string', description: '#string', powers: '#[]' }

  @id:2 @obtenerPersonajesId
  Scenario: Obtener personaje por ID exitoso
    * def result = call read('karate-test.feature@obtenerPersonajes')
    * def characterId = result.response[0].id
    * def name = result.response[0].name
    Given path 'characters', characterId
    When method GET
    Then status 200
    And match response.name == name
    And match response == { id: '#number', name: '#string', alterego: '#string', description: '#string', powers: '#[]' }

  @id:3 @obtenerPersonajesNone
  Scenario: Obtener personaje por ID inexistente
    * def characterId = 9999999
    * print characterId
    Given path 'characters', characterId
    When method GET
    Then status 404
    And match response.error == 'Character not found'

  @id:4 @crearPersonajeDuplicado
  Scenario: Crear personaje con nombre duplicado
    * def result = call read('karate-test.feature@crearPersonajeExitoso')
    * def characterId = result.response.id
    * def characterName = result.response.name
    * def alterego = result.response.alterego
    * def description = result.response.description
    * def powers = result.response.powers
    Given path 'characters'
    And request { "name": #(characterName), "alterego": #(alterego), "description": #(description), "powers": #(powers) }
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'

  @id:5 @crearPersonajeSinData
  Scenario: Crear personaje con campos vacíos
    Given path 'characters'
    And request { "name": "", "alterego": "", "description": "", "powers": [] }
    When method POST
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  @id:6 @crearPersonajeExitoso
  Scenario: Crear personaje exitosamente
    * def randomId = java.util.UUID.randomUUID().toString()
    * def characterName = 'Iron Man Infernal Karate -' + randomId
    Given path 'characters'
    And request { "name": #(characterName), "alterego": "Tony Stark", "description": "Genius billionaire", "powers": ["Armor", "Flight"] }
    When method POST
    Then status 201
    And match response.name == characterName
    And match response.id != null



  @id:7 @acutalizarPersonajeExitoso
  Scenario: Actualizar personaje exitosamente
    * def result = call read('karate-test.feature@crearPersonajeExitoso')
    * def characterId = result.response.id
    Given path 'characters', characterId
    And request { "name": "Iron Man", "alterego": "Tony Stark", "description": "Updated description", "powers": ["Armor", "Flight"] }
    When method PUT
    Then status 200
    And match response.description == 'Updated description'
    * print characterId

  @id:8 @acutalizarPersonajeNoExistente
  Scenario: Actualizar personaje inexistente
    * def characterId = 9999999
    Given path 'characters', characterId
    And request { "name": "Iron Man", "alterego": "Tony Stark", "description": "Updated description", "powers": ["Armor", "Flight"] }
    When method PUT
    Then status 404
    And match response.error == 'Character not found'
    * print characterId

  @id:9 @eliminarPersonajeExistente
  Scenario: Eliminar personaje Existente
    * def result = call read('karate-test.feature@crearPersonajeExitoso')
    * def characterId = result.response.id
    Given path 'characters', characterId
    When method DELETE
    Then status 204

  @id:10 @eliminarPersonajeInexistente
  Scenario: Eliminar personaje inexistente
    * def characterId = 9999999
    Given path 'characters', characterId
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'