import type { AstNode, MaybePromise } from 'langium';
import { AstNodeHoverProvider } from 'langium/lsp';
import { isAgent, isDataSource, isTool } from './generated/ast.js';

// Class of langium/lsp 
export class AgentDbHoverProvider extends AstNodeHoverProvider {

    protected override getAstNodeHoverContent(node: AstNode): MaybePromise<string | undefined> {

        // Returns de description of the agent with its name, number of tools and number of data sources 
        if (isAgent(node)) {
            const toolsCount = node.tools ? node.tools.length : 0;
            const dsCount = node.dataSources ? node.dataSources.length : 0;

            return [
                `Agente: \`${node.name}\``,
                `- Herramientas definidas: ${toolsCount}`,
                `- Fuentes de datos: ${dsCount}`
            ].join(`\n`);
        }

        // Returns de description of the tool with its name, description, dataSource and operation 
        if (isTool(node)) {
            const dsName = node.dataSource?.ref ? node.dataSource.ref.name : `No definida`;
            const operation = node.operation ? node.operation : `Sin operación`;
            const description = node.description ? node.description : `Sin descripcion`;

            return [
                `Herramienta: \`${node.name}\``,
                `${description}`,
                `- Fuente de datos: \`${dsName}\``,
                `- Operacion: \`${operation}\``
            ].join(`\n`);
        }

        // Returns the description of the data source with its name and type
        if (isDataSource(node)) {
            const dbType = node.type ? node.type : `Desconocido`;

            return [
                `Fuente de datos: \`${node.name}\``,
                `- Tipo: \`${dbType}\``,
            ].join(`\n`);
        }

        return undefined;
    }
}