//
//  HomeScreen.swift
//  Dex
//
//  Created by Mahesh Bansode on 01/01/26.
//


import SwiftUI
import CoreData

struct HomeScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokemons: FetchedResults<Pokemon>
    
    let fetcher = PokemonService()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pokemons) { pokemon in
                    NavigationLink {
                        Text(pokemon.name ?? "Unknown")
                    } label: {
                        Text(pokemon.name ?? "Unknown")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        fetchPokemons()
                    }
                }
            }
        }
//        .preferredColorScheme(.dark)
    }
    
    private func fetchPokemons() {
        Task {
            for id in 1..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(byID: id)
                    
                    let pokemon = Pokemon(context: viewContext)
                    
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    try viewContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    HomeScreen().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
