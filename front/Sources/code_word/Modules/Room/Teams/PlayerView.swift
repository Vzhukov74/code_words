//
//  PlayerView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

struct PlayerView: View {
    
    let player: Player
    
    var body: some View {
        HStack {
            Text(player.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
