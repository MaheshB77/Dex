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
    @State private var searchStr = ""
    @State private var filterByFavorites = false

    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []

        // Search predicate
        if !searchStr.isEmpty {
            predicates.append(
                NSPredicate(format: "name contains[c] %@", searchStr)
            )
        }

        // Filter predicate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }

        // Combine and return
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokemons) { pokemon in
                    NavigationLink {
                        PokemonDetails()
                            .environmentObject(pokemon)
                    } label: {
                        if (pokemon.spriteImg != nil) {
                            Image(uiImage: UIImage(data: pokemon.spriteImg!)!)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                
                        } else {
                            AsyncImage(url: pokemon.sprite) { img in
                                img
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text(pokemon.name?.capitalized ?? "Unknown")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                }

                            }

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
                    .swipeActions(edge: .leading) {
                        Button(
                            pokemon.favorite
                                ? "Remove from favorites" : "Add to favorites"
                        ) {
                            pokemon.favorite.toggle()
                            do {
                                try viewContext.save()
                            } catch {
                                print(
                                    "Failed to update favorite status: \(error)"
                                )
                            }
                        }
                        .tint(pokemon.favorite ? .gray : .yellow)
                    }
                }
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchStr, prompt: "Search Pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchStr) {
                pokemons.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavorites) {
                pokemons.nsPredicate = dynamicPredicate
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        "Favorites",
                        systemImage: filterByFavorites ? "star.fill" : "star"
                    ) {
                        filterByFavorites.toggle()

                    }
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "arrow.clockwise") {
                        fetchPokemons()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
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
            storeImages()
        }
    }

    private func storeImages() {
        Task {
            do {
                for pokemon in pokemons {
                    pokemon.spriteImg = try await URLSession.shared.data(
                        from: pokemon.sprite!
                    ).0
                    pokemon.shinyImg = try await URLSession.shared.data(
                        from: pokemon.shiny!
                    ).0
                    
                    try viewContext.save()
                    
                    print("Stored images for \(pokemon.name ?? "unknown")")
                }
            } catch {
                print("Error while fetching images: \(error)")
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
