//
//  TeamsView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

struct Teams: Identifiable, Hashable {
    let id: String
    let blue: [Player]
    let red: [Player]
}

extension Teams {
    static var random: Teams {
        Teams(
            id: UUID().uuidString,
            blue: [Player.random, Player.random, Player.random, Player.random],
            red: [Player.random, Player.random, Player.random, Player.random]
        )
    }
}

struct TeamsView: View {
    
    let teams: Teams
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                ForEach(teams.red, id: \.self) { player in
                    PlayerView(player: player)
                        .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .background { Color.red }
            VStack(alignment: .leading) {
                ForEach(teams.blue, id: \.self) { player in
                    PlayerView(player: player)
                        .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .background { Color.blue }
        }
    }
}

#Preview {
    TeamsView(teams: .random)
}
