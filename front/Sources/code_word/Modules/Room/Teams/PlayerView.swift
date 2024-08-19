//
//  PlayerView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

struct Player: Identifiable, Hashable {
    let id: String
    let name: String
}

extension Player {
    static var random: Player {
        Player(
            id:  UUID().uuidString, 
            name: ["Вася", "Петя", "Оля", "Света", "Сергей", "Олег", "Лиза"].randomElement()!
        )
    }
}

struct PlayerView: View {
    
    let player: Player
    
    var body: some View {
        HStack {
            Text(player.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PlayerView(player: Player.random)
}
