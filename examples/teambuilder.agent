agent TeamBuilder {
    description "Asistente para seleccionar personajes y buscar sinergias entre sus habilidades."

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
            unlocked: string
            characterClass: string
            minLevel: string?
        }
    }

    tool findSkillTeamwork {
        description "Busca que habilidades se complementan mejor con la habilidad principal."
        datasource SkillSynergyGraph
        operation traverse
        parameters {
            primarySkill: string
            targetRole: string
        }
    }

    policy {
        readOnly
        maximumResults 4
        forbid modifyHeroStats
        forbid showLockedHeros
        hide "character.internalId" with "[HIDDEN]"
    }

    instructions {
        "Prioriza sugerir personajes que complementen las debilidades actuales del equipo."
        "No sugieras personajes que esten marcados como bloqueados."
    }
}