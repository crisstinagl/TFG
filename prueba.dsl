agent StoreAssistant {
    
    description "Asistente para consultar productos"

    datasource Catalog {
        type mongodb
        flow "search-products"
    }

    datasource ProductGraph {
        type neo4j
        flow "find-related-products"
    }

    tool searchProducts {
        datasource Catalog
        operation find
    }

    tool findCompatibleProducts {
        datasource ProductGraph
        operation traverse
    }

    policy {
        readOnly
        maximumResults 20
        forbid delete
        forbid update
        hide "customer.email"
        hide "customer.password"
    }

    instructions {
        "No inventes precios."
        "Utiliza MongoDB para buscar productos."
        "Utiliza Neo4j para buscar productos compatibles."
    }
}