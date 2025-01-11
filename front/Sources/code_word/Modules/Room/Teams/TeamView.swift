//
//  TeamView.swift
//  project-name
//
//  Created by Vladislav Zhukov on 11.01.2025.
//

import SwiftUI

struct TeamView: View {
    
    let team: Team
    let isStatic: Bool
    let isNeedSelectLastWord: Bool
    let onBecameLeader: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            leaderView
            teamList
            hintWordsList
        }
    }
    
    @ViewBuilder
    private var teamList: some View {
        VStack(spacing: 8) {
            if !team.players.isEmpty {
                Divider()
                    .padding(.bottom, 8)
                ForEach(team.players, id: \.self) { player in
                    PlayerView(player: player, hasVote: team.votes.contains(where: { $0.playerId == player.id }))
                }
            } else {
                EmptyView()
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
    private var hintWordsList: some View {
        if !team.words.isEmpty {
            Divider()
                .padding(.bottom, 8)
            ForEach(team.words.indices, id: \.self) { index in
                Text("\(team.words[index].word) \(team.words[index].number)")
                    .font(.system(size: 16))
                    .fontWeight(((index == team.words.count - 1) && isNeedSelectLastWord) ? .bold : .regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            EmptyView()
        }
    }
    
    private var leaderView: some View {
        HStack(spacing: 12) {
            leaderLabel
            if isStatic {
                Text("\(team.countWords - team.openWords)")
                    .font(.system(size: 26))
                    .fontWeight(.regular)
            }
        }
    }
    
    @ViewBuilder
    private var leaderLabel: some View {
        if team.leader != nil || isStatic {
            PlayerView(player: team.leader ?? .empty, hasVote: false)
        } else {
            Button(action: { onBecameLeader() }) {
                Text("became a team master")
            }
        }
    }
}

private extension Player {
    static var empty: Player {
        Player(id: "", name: "oops no leader!", icon: 0)
    }
}
