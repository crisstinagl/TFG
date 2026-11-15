grammar AgentDb

// Terminales ocultos: espacios, tabulaciones, saltos de linea y comentarios (// y /**/)
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

// Terminales de datos (tokens)
terminal ID: /[_a-zA-Z][\w_]*/;
terminal STRING: /"[^"]*"|'[^']*'/;
terminal INT returns number: /[0-9]+/;

entry Model:
    agents+=Agent*
;

Agent:
    'agent' name=ID '{'
        'description' description=STRING
        dataSources+=DataSource*
        tools+=Tool*
        policy=Policy?
        instructions=Instructions?
    '}'
;

DataSource:
    'datasource' name=ID '{'
        'type' type=DatabaseType
        'flow' flow=STRING
    '}'
;

DatabaseType returns string:
    'mongodb' | 'neo4j'
;

Tool:
    'tool' name=ID '{'
        ('description' description=STRING)?
        'datasource' dataSource=[DataSource:ID]
        'operation' operation=ID
        ('parameters' '{' parameters+=Parameter* '}')?
    '}'
;

Parameter:
    name=ID ':' type=ID ('?')?
;

Policy:
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

Instructions:
    'instructions' '{'
        items+=STRING*
    '}'
;
