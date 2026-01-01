//
//  PokemonService.swift
//  Dex
//
//  Created by Mahesh Bansode on 01/01/26.
//

import Foundation

class PokemonService {
    enum FetchError: Error {
        case badResponse
    }
    
    let baseURL: URL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    func fetchPokemon(byID id: Int) async throws -> FetchedPokemon {
        let fetchURL = baseURL.appending(path: String(id))
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(FetchedPokemon.self, from: data)
        print("Fetched pokemon \(pokemon.id) -> \(pokemon.name)")
        
        return pokemon
    }
}
