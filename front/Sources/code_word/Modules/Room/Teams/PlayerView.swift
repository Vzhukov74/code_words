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
        HStack(spacing: 6) {
            if player.icon != nil {
                PlayerAvatars.image(by: player.icon!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.red)
                    .frame(width: 20, height: 20)
            }
            
            Text(player.name)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
