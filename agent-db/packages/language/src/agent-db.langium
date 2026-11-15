// Nombre gramatica
grammar AgentDb

// Terminales ocultos: espacios, tabulaciones, saltos de linea y comentarios (// y /**/)
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

// Terminales de datos (tokens)
terminal ID: /[_a-zA-Z][\w_]*/;
terminal STRING: /"[^"]*"|'[^']*'/;
terminal INT returns number: /[0-9]+/;

// ------------------------
// INTERFACES
// ------------------------

interface Model {
    agents: Agent[]
}

interface Agent {
    name: string
    description?: string // Opcional
    dataSources: DataSource[]
    tools: Tool[]
    policy: Policy
    instructions: Instructions
}

interface DataSource {
    name: string
    type: string
    flow: string
}

interface Tool{
    name: string
    description?: string // Opcional
    dataSource: @DataSource // Referencia cruzada
    operation: string
    parameters: Parameter[]
}

interface Parameter {
    name: string
    type: string
    isOptional?: boolean
}

interface Policy {
    rules: string[]
}

interface Instructions {
    items: string[]
}

// ------------------------
// GRAMATICA
// ------------------------

entry Model returns Model:
    agents+=Agent*
;

Agent returns Agent:
    'agent' name=ID '{'
        (
            'description' description=STRING 
            dataSources+=DataSource* 
            tools+=Tool* 
            policy=Policy
            instructions=Instructions
        )
    '}'
;

DataSource returns DataSource:
    'datasource' name=ID '{'
        (
            'type' type=DatabaseType
            'flow' flow=STRING
        )
    '}'
;

DatabaseType returns string:
    'mongodb' | 'neo4j'
;

Tool returns Tool:
    'tool' name=ID '{'
        ('description' description=STRING)?
        'datasource' dataSource=[DataSource:ID]
        'operation' operation=ID
        ('parameters' '{' parameters+=Parameter* '}')?
    '}'
;

Parameter returns Parameter:
    name=ID ':' type=ID (isOptional?='?')?
;

Policy returns Policy:
    'policy' '{'
        rules+=PolicyRule*
    '}'
;

PolicyRule returns string:
    'readOnly' 
    | 'maximumResults' INT 
    | 'forbid' ID 
    | 'hide' STRING ('with' STRING)?
;

Instructions returns Instructions:
    'instructions' '{'
        items+=STRING*
    '}'
;
