//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Mahesh Bansode on 01/01/26.
//

import Foundation

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let sprite: URL
    let shiny: URL

    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites

        enum TypeDictionaryKeys: CodingKey {
            case type

            enum TypeKeys: CodingKey {
                case name
            }
        }

        enum StatsDictionaryKeys: CodingKey {
            case baseStat
        }

        enum SpriteKeys: String, CodingKey {
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)

        // Decode types
        var typesContainer = try container.nestedUnkeyedContainer(
            forKey: .types
        )
        var decodedTypes: [String] = []
        while !typesContainer.isAtEnd {
            let typeDictionaryContainer = try typesContainer.nestedContainer(
                keyedBy: CodingKeys.TypeDictionaryKeys.self
            )
            let typeContainer = try typeDictionaryContainer.nestedContainer(
                keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self,
                forKey: .type
            )
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        self.types = decodedTypes

        // Decode stats
        var statsContainer = try container.nestedUnkeyedContainer(
            forKey: .stats
        )
        var baseStats: [Int16] = []
        while !statsContainer.isAtEnd {
            var statsDictionaryContainer = try statsContainer.nestedContainer(
                keyedBy: CodingKeys.StatsDictionaryKeys.self
            )
            let baseStat = try statsDictionaryContainer.decode(
                Int16.self,
                forKey: .baseStat
            )
            baseStats.append(baseStat)
        }
        self.hp = baseStats[0]
        self.attack = baseStats[1]
        self.defense = baseStats[2]
        self.specialAttack = baseStats[3]
        self.specialDefense = baseStats[4]
        self.speed = baseStats[5]

        // Decode sprites
        var spriteDictionary = try container.nestedContainer(
            keyedBy: CodingKeys.SpriteKeys.self,
            forKey: .sprites
        )
        self.sprite = try spriteDictionary.decode(URL.self, forKey: .sprite)
        self.shiny = try spriteDictionary.decode(URL.self, forKey: .shiny)
    }
}
