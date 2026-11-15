import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { AgentDbAstType, Agent } from './generated/ast.js';
import type { AgentDbServices } from './agent-db-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: AgentDbServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.AgentDbValidator;
    const checks: ValidationChecks<AgentDbAstType> = {
        Agent: validator.checkAgentStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class AgentDbValidator {

    checkAgentStartsWithCapital(agent: Agent, accept: ValidationAcceptor): void {
        if (agent.name) {
            const firstChar = agent.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Agent name should start with a capital.', { node: agent, property: 'name' });
            }
        }
    }

}
