agent StoreAssistant {
    
    description "Asistente para consultar productos de una tienda"

    datasource Catalog {
        type mongodb
        flow "search-products"
    }

    datasource Recommendations {
        type neo4j
        flow "find-related-products"
    }

    tool searchProducts {
        description "Esta herramienta se usa para buscar productos dentro de un catalogo."
        datasource Catalog
        operation find
        parameters {
            query: string
            category: string?
        }
    }

    tool findCompatibleProducts {
        description "Esta herramienta SOLO se usa para buscar productos compatibles con un producto principal."
        datasource Recommendations
        operation traverse
        parameters {
            productId: string
        }
    }

    policy {
        readOnly
        maximumResults 20
        forbid delete
        forbid update
        hide "customer.email" with "[PROTECTED]"
        hide "customer.password" with "*"
    }

    instructions {
        "No inventes precios."
        "No inventes productos."
        "No inventes relaciones."
        "Si la consulta realizada no devuelve resultados, indica explícitamente que no hay stock, no sugieras otro producto."
        "Si la consulta realizada devuelve más resultados del límite máximo permitido, notifica al usuario de que hay más opciones disponibles de las mostradas."
        "Utiliza MongoDB para buscar productos."
        "Utiliza Neo4j para buscar productos compatibles."
    }
}