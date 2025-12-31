//
//  ContentView.swift
//  Dex
//
//  Created by Mahesh Bansode on 31/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokemons: FetchedResults<Pokemon>
    
    var body: some View {
        NavigationView {
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
                        
                    }
                }
            }
            Text("Select an item")
        }
    }
    
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
