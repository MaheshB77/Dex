//
//  PokemonDetails.swift
//  Dex
//
//  Created by Mahesh Bansode on 02/01/26.
//

import SwiftUI
import CoreData

struct PokemonDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var pokemon: Pokemon
    @State private var showShiny = false
    
    var body: some View {
        
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 4)
                    .padding()
                
                AsyncImage(url: pokemon.sprite) { img in
                    img
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 40)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }
            }
            
            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .fontWeight(.semibold)
                        .padding(12)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                        .shadow(radius: 4)
                }
                .padding(.leading, 12)
                .padding(.top, 8)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text("Stats")
                    .font(.title)
                    .padding([.leading, .top])
                StatsScreen(pokemon: pokemon)
            }
            
                
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    "Favorites",
                    systemImage: pokemon.favorite ? "star.fill" : "star"
                ) {
                    pokemon.favorite.toggle()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to update favorite status: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetails()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
