# Security Group Checker :male_detective:

Bot que remove portas sensíveis liberadas para a internet 

# Como funciona? :mage:

Este serviço trabalha basicamente no seguinte fluxo:<br>
    1 - EventBridge é ativado em toda nova ação de autorização de security group<br>
    2 - Um Lambda é triggado pelo event bridge e recebe o evento para validar<br>
    3 - O Lambda valida se a liberação foi feita para a internet em uma porta sensível e caso positivo remove a liberação<br>
    4 - Após realizar a remoção da liberação do security group, ele notifica o evento no Slack<br>

