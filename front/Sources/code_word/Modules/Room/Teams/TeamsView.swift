//
//  TeamsView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

struct TeamsView: View {
    
    let state: GState
    
    let onBecameRedLeader: () -> Void
    let onJoinRed: () -> Void
    let onBecameBlueLeader: () -> Void
    let onJoinBlue: () -> Void
    let isStatic: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading) {
                TeamView(
                    team: state.teams[0], // red team
                    isStatic: isStatic,
                    isNeedSelectLastWord: state.phase == .red,
                    onBecameLeader: onBecameRedLeader,
                    onJoin: onJoinRed
                )
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading) {
                TeamView(
                    team: state.teams[1], // red team
                    isStatic: isStatic,
                    isNeedSelectLastWord: state.phase == .blue,
                    onBecameLeader: onBecameBlueLeader,
                    onJoin: onJoinBlue
                )
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
        }
            .frame(minHeight: 60)
            .background {
                TeamsBgColors()
            }
    }
}

// Helper

struct TeamsStaticView: View {
    let state: GState
    
    var body: some View {
        TeamsView(
            state: state,
            onBecameRedLeader: {},
            onJoinRed: {},
            onBecameBlueLeader: {},
            onJoinBlue: {},
            isStatic: true
        )
    }
}
