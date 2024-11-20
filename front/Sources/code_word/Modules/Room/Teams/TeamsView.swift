//
//  TeamsView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

struct TeamsBgColors: View {
    var body: some View {
        HStack(spacing: 0) {
            AppColor.red
                .frame(maxWidth: .infinity)
            AppColor.blue
                .frame(maxWidth: .infinity)
        }
    }
}

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

struct TeamsView: View {
    
    let state: GState
    
    let onBecameRedLeader: () -> Void
    let onJoinRed: () -> Void
    let onBecameBlueLeader: () -> Void
    let onJoinBlue: () -> Void
    let isStatic: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                TeamView(
                    leader: state.readTeamLeader,
                    players: state.redTeam,
                    isStatic: isStatic,
                    onBecameLeader: onBecameRedLeader,
                    onJoin: onJoinRed
                )
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading) {
                TeamView(
                    leader: state.blueTeamLeader,
                    players: state.blueTeam,
                    isStatic: isStatic,
                    onBecameLeader: onBecameBlueLeader,
                    onJoin: onJoinBlue
                )
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
        }
            .frame(minHeight: 60)
            .background {
                TeamsBgColors()
            }
    }
}

private struct TeamView: View {
    
    let leader: Player?
    let players: [Player]
    let isStatic: Bool
    let onBecameLeader: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            leaderView
            Divider()
            ForEach(players, id: \.self) { player in
                PlayerView(player: player)
            }
            if !isStatic {
                Divider()
                Button(action: onJoin) {
                    Text("join")
                }
            }
        }
    }
    
    @ViewBuilder
    private var leaderView: some View {
        if leader != nil || isStatic {
            PlayerView(player: leader ?? Player(id: "", name: "oops no leader!"))
        } else {
            Button(action: { onBecameLeader() }) {
                Text("became a team master")
            }
        }
    }
}
