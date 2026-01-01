//
//  HomeScreen.swift
//  Dex
//
//  Created by Mahesh Bansode on 01/01/26.
//

import CoreData
import SwiftUI

struct HomeScreen: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest<Pokemon>(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)
        ],
        animation: .default
    )
    private var pokemons
    private let fetcher = PokemonService()
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        // Search predicate
        if !searchStr.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchStr))
        }
        
        // Filter predicate
        
        // Combine and return
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    @State private var searchStr = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokemons) { pokemon in
                    NavigationLink {
                        Text(pokemon.name ?? "Unknown")
                    } label: {
                        AsyncImage(url: pokemon.sprite) { img in
                            img
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                        VStack(alignment: .leading) {
                            Text(pokemon.name?.capitalized ?? "Unknown")
                                .font(.title2)
                                .fontWeight(.bold)

                            HStack {
                                ForEach(pokemon.types ?? [], id: \.self) {
                                    type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color(type.capitalized))
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchStr, prompt: "Search Pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchStr) {
                pokemons.nsPredicate = dynamicPredicate
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
                    let fetchedPokemon = try await fetcher.fetchPokemon(
                        byID: id
                    )

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
    HomeScreen().environment(
        \.managedObjectContext,
        PersistenceController.preview.container.viewContext
    )
}
