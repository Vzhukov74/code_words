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
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                TeamView(
                    leader: state.readTeamLeader,
                    players: state.redTeam,
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
                    onBecameLeader: onBecameBlueLeader,
                    onJoin: onJoinBlue
                )
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
        }
            .frame(minHeight: 60)
            .background {
                HStack(spacing: 0) {
                    AppColor.red
                        .frame(maxWidth: .infinity)
                    AppColor.blue
                        .frame(maxWidth: .infinity)
                }
            }
    }
}

private struct TeamView: View {
    
    let leader: Player?
    let players: [Player]
    let onBecameLeader: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            leaderView
            Divider()
            ForEach(players, id: \.self) { player in
                PlayerView(player: player)
            }
            Divider()
            Button(action: onJoin) {
                Text("join")
            }
        }
    }
    
    @ViewBuilder
    private var leaderView: some View {
        if leader != nil {
            PlayerView(player: leader!)
        } else {
            Button(action: { logger.info("123"); onBecameLeader() }) {
                Text("became a team master")
            }
        }
    }
}
