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
                    team: state.teams[0], // red team
                    isStatic: isStatic,
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

private struct TeamView: View {
    
    let team: Team
    let isStatic: Bool
    let onBecameLeader: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            leaderView
            Divider()
            ForEach(team.players, id: \.self) { player in
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
        if team.leader != nil || isStatic {
            PlayerView(player: team.leader ?? Player(id: "", name: "oops no leader!", icon: nil))
        } else {
            Button(action: { onBecameLeader() }) {
                Text("became a team master")
            }
        }
    }
}
