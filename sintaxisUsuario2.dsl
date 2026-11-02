agent PartyBuilder {
    description "Asistente para reclutar personajes y buscar sinergias entre sus habilidades."

    datasource CharacterRoster {
        type mongodb
        flow "fetch-character-profiles"
    }

    datasource SkillSynergyGraph {
        type neo4j
        flow "analyze-skill-combos"
    }

    tool findHeroByClass {
        description "Busca personajes disponibles en el catalogo filtrando por clase y nivel."
        datasource CharacterRoster
        operation find
        parameters {
            characterClass: string
            minLevel: string?
        }
    }

    tool findSkillTeamwork {
        description "Busca que habilidades reaccionan mejor con la habilidad principal."
        datasource SkillSynergyGraph
        operation traverse
        parameters {
            primarySkill: string
            targetRole: string
        }
    }

    policy {
        readOnly
        maximumResults 12
        forbid modifyHeroStats
        hide "character.hiddenMMR" with "[HIDDEN]"
        hide "character.internalId" with "[REDACTED]"
    }

    instructions {
        "Prioriza sugerir personajes que complementen las debilidades actuales del equipo."
        "No sugieras personajes que estén marcados como bloqueados o en tiempo de recuperación."
        "Garantiza que la sinergia recomendada aplique estados alterados efectivos (ej. Agua + Rayo)."
    }
}