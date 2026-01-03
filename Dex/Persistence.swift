//
//  Persistence.swift
//  Dex
//
//  Created by Mahesh Bansode on 31/12/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    static var previewPokemon: Pokemon {
        let context = PersistenceController.preview.container.viewContext

        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        let results = try! context.fetch(fetchRequest)

        return results.first!
    }

    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 132
        newPokemon.name = "ditto"
        newPokemon.types = ["normal"]
        newPokemon.hp = 48
        newPokemon.attack = 48
        newPokemon.defense = 48
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.sprite = URL(
            string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/132.png"
        )
        newPokemon.shiny = URL(
            string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/132.png"
        )

        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        } else {
            // This stores the data in App Group container for sharing between app and widgets
            container.persistentStoreDescriptions.first!.url = FileManager
                .default
                .containerURL(
                    forSecurityApplicationGroupIdentifier:
                        "group.com.mahesh.DexGroup"
                )!.appending(path: "Dex.sqlite")
        }
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error)")
            }
        })
        container.viewContext.mergePolicy =
            NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
