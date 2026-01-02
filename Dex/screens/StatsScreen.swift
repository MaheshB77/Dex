//
//  StatsScreen.swift
//  Dex
//
//  Created by Mahesh Bansode on 03/01/26.
//

import Charts
import SwiftUI

struct StatsScreen: View {
    let pokemon: Pokemon
    var body: some View {
        Chart(pokemon.stats) { stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stat", stat.name)
            )
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 220)
        .padding([.horizontal, .bottom])
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.highestStat.value + 12)
    }
}

#Preview {
    StatsScreen(pokemon: PersistenceController.previewPokemon)
}
