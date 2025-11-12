*** Settings ***
Documentation    Exemplo de teste adaptado ao App Flask (WTForms + SQLite).
...              Testa UI, Banco de Dados e demonstra API.

Library          RequestsLibrary
Library          DatabaseLibrary
Library          JSONLibrary
Library          SeleniumLibrary

Suite Setup      Conectar Ao Banco de Dados
Suite Teardown   Desconectar Do Banco de Dados


*** Variables ***
${URL_BASE}          http://127.0.0.1:5000
${URL_CADASTRO}      ${URL_BASE}/cadastro/
${DB_CONNECT_STRING}  database.db
${DB_DRIVER}         sqlite3
${NAVEGADOR}         Chrome

${API_EXTERNA_URL}   https://reqres.in/api


*** Test Cases ***
Teste 1: Cadastrar Usuário via UI e Verificar no Banco (Selenium + Database)
    [Tags]    flask_app    ui_e_banco

    Open Browser    ${URL_CADASTRO}    ${NAVEGADOR}
    Maximize Browser Window
    Wait Until Page Contains Element    id:nome

    Input Text    id:nome                  Yuri
    Input Text    id:sobrenome             Alberto
    Input Text    id:email                 yuri.alberto@corinthians.com
    Input Text    id:senha                 Gol1234
    Input Text    id:confirmacao_senha     Gol1234

    Click Button    id:btnSubmit

    Wait Until Location Is    ${URL_BASE}/

    [Teardown]    Close Browser


    ${query} =    Set Variable    SELECT email, sobrenome FROM user WHERE nome = 'Yuri'
    ${resultado_db} =    Query    ${query}
    
    Should Be Equal As Strings    ${resultado_db[0][0]}    yuri.alberto@corinthians.com
    Should Be Equal As Strings    ${resultado_db[0][1]}    Alberto


Teste 2: Validar API Externa (Requests + JSON)
    [Tags]    exemplo_api    requests_e_json


    Create Session    minha_sessao_api_externa    ${API_EXTERNA_URL}
    
 
    ${resposta} =    GET On Session    minha_sessao_api_externa    /users/2
    

    Should Be Equal As Strings    ${resposta.status_code}    200
    

    ${json_obj} =    To Json    ${resposta.content}
    Validate Json    ${json_obj}    {"data": {"id": 2, "email": "janet.weaver@reqres.in", "first_name": "Janet", "last_name": "Weaver"}}


*** Keywords ***
Conectar Ao Banco de Dados

    Connect To Database    ${DB_DRIVER}    ${DB_CONNECT_STRING}

Desconectar Do Banco de Dados

    Disconnect From Database