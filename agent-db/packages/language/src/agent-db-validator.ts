import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { AgentDbAstType, Agent, Tool } from './generated/ast.js';
import type { AgentDbServices } from './agent-db-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: AgentDbServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.AgentDbValidator;
    const checks: ValidationChecks<AgentDbAstType> = {
        Agent: [
            validator.checkAgentStartsWithCapital,
            validator.checkUniqueNames, // Validar nombres unicos
            validator.checkReadOnlyPolicy // Validar operaciones de solo lectura
        ],
        Tool: validator.checkOperationCompatibility // Validar compatibilidad de la herramienta con la base de datos
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class AgentDbValidator {

    // Evitar que el nombre del agente empiece con una minuscula
    checkAgentStartsWithCapital(agent: Agent, accept: ValidationAcceptor): void {
        if (agent.name) {
            const firstChar = agent.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept(`warning`, `Agent name should start with a capital.`, { node: agent, property: `name` });
            }
        }
    }

    // Evitar nombres duplicados en Tools y en DataSources
    checkUniqueNames(agent: Agent, accept: ValidationAcceptor): void {
        const toolNames = new Set<string>();
        for (const tool of agent.tools ?? []) {
            if (toolNames.has(tool.name)) {
                accept('error', `La herramienta '${tool.name}' esta duplicada en el agente '${agent.name}'`, {
                    node: tool,
                    property: 'name'
                });
            } else {
                toolNames.add(tool.name);
            }
        }

        const dataSrcNames = new Set<string>();
        for (const dSrc of agent.dataSources ?? []) {
            if (dataSrcNames.has(dSrc.name)) {
                accept('error', `La fuente de datos '${dSrc.name}' esta duplicada en el agente '${agent.name}'`, {
                    node: dSrc,
                    property: 'name'
                })
            } else {
                dataSrcNames.add(dSrc.name);
            }
        }
    }

    // Validar que no se puedan utilizar operaciones de escritura en herramientas de solo lectura
    checkReadOnlyPolicy(agent: Agent, accept: ValidationAcceptor): void {
        const isReadOnly = agent.policy?.rules?.includes(`readOnly`); // Al no tratarse de un bool se accede a la variable
        if(!isReadOnly) {
            return;
        }

        const writeOperations = [`insert`, `update`, `delete`, `create`];
        for (const tool of agent.tools ?? []) {
            if (tool.operation && writeOperations.includes(tool.operation.toLowerCase())) {
                accept('error', `La herramienta '${tool.name}' usa la operacion '${tool.operation}', pero el agente esta configurado como 'readOnly'`, {
                    node: tool,
                    property: 'operation'
                });
            }
        }
    }

    checkOperationCompatibility(tool: Tool, accept: ValidationAcceptor): void {
        const ds = tool.dataSource?.ref;
        if (!ds) {
            return;
        }

        if (tool.operation === `traverse` && ds.type === `mongodb`) {
            accept('error', `La operacion 'traverse' es propia de bases de datos de grafos (Neo4j) y no es compatible con '${ds.name}' (mongodb).`, {
                node: tool,
                property: 'operation'
            });
        }
    }
}
