//
//  RoomGameIdle.swift
//  project-name
//
//  Created by Владислав Жуков on 20.11.2024.
//
import SwiftUI

struct RoomGameIdle: View {
    
    let state: GState
    
    let isHost: Bool
    let onShareGame: () -> Void
    let onStartGame: () -> Void
    let onBecameRedLeader: () -> Void
    let onBecameBlueLeader: () -> Void
    let onJoinRed: () -> Void
    let onJoinBlue: () -> Void
    
    var body: some View {
        VStack {
            TeamsView(
                state: state,
                onBecameRedLeader: onBecameRedLeader,
                onJoinRed: onJoinRed,
                onBecameBlueLeader: onBecameBlueLeader,
                onJoinBlue: onJoinBlue,
                isStatic: false
            )
            Spacer()
            
            Text("Пригласить участников")
            
            Spacer()
            // if current user is host, start game button
            if isHost {
                AppMainButton(
                    title: "Начать",
                    action: onStartGame,
                    color: AppColor.main
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }
}
