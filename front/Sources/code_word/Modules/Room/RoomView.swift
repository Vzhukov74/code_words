//
//  RoomView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

public struct RoomView: View {
    @StateObject var vm: RoomViewModel
    
    // MARK: State
    
    @State var isLoading: Bool = true
    @State var state: GState?
    
    private var isLeader: Bool {
        guard let state else { return false }

        return state.teams[0].leader?.id == vm.user.id ||
        state.teams[1].leader?.id == vm.user.id
    }
    
    private var hasHintInput: Bool {
        guard let state else { return false }
        
        if state.teams[0].leader?.id == vm.user.id && state.phase == .redLeader {
            return true
        } else if state.teams[1].leader?.id == vm.user.id && state.phase == .blueLeader {
            return true
        } else {
            return false
        }
    }
    
    private var canSelect: Bool {
        guard let state else { return false }
        guard state.phase == .red ||  state.phase == .blue else { return false }
        
        return state.teams[0].players.contains(where: { $0.id == vm.user.id }) || state.teams[1].players.contains(where: { $0.id == vm.user.id })
    }
    
    // MARK: UI
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TeamsBgColors()
                    .ignoresSafeArea(.all)
                    .frame(height: 100)
                Spacer()
            }
            content
        }.onAppear { prepare() }
    }
    
    private var content: some View {
        Group {
            if isLoading {
                VStack(alignment: HorizontalAlignment.center, spacing: CGFloat(16)) {
                    ProgressView()
                    Text("Подключаемся...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
                    .frame(maxHeight: CGFloat.infinity)
            } else {
                if state != nil {
                    gameView(state!)
                } else {
                    Text("Ошибка...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            Text(state?.phase.title ?? "")
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundStyle(.black)
            HStack {
                Button(action: vm.onBack) {
                    Image("chevron", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.main)
                        .frame(width: 24, height: 24)
                        .offset(x: -10)
                }
                .frame(width: 44, height: 44)
                Spacer(minLength: 0)
                Button(action: { vm.startGame() }) {
                    Image("action", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.main)
                        .frame(width: 24)
                        .offset(x: 10)
                }
                .frame(width: 44, height: 44)
            }
        }
            .frame(height: 44)
            .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func gameView(_ state: GState) -> some View {
        switch state.phase {
        case .idle:
            gameIdle(state)
        case .endBlue, .endRed:
            Text("123")
        case .redLeader, .red, .blueLeader, .blue:
            game(state)
        }
    }
    
    private func gameIdle(_ state: GState) -> some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
            RoomGameIdle(
                state: state,
                isHost: true,
                onShareGame: {},
                onStartGame: vm.startGame,
                onBecameRedLeader: vm.onBecameRedLeader,
                onBecameBlueLeader: vm.onBecameBlueLeader,
                onJoinRed: vm.onJoinRed,
                onJoinBlue: vm.onJoinBlue
            )
        }
    }
    
    private func game(_ state: GState) -> some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 10)
            TeamsStaticView(
                state: state
            )
            hintInput(state)
                .padding(.top, 12)
            Spacer()
            GameWordsView(
                words: state.words,
                isOpen: isLeader,
                canSelect: canSelect,
                selected: prepareVotes(state),
                onSelect: vm.onSelect(_:)
            )
                .padding(.horizontal, 8)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func hintInput(_ state: GState) -> some View {
        if hasHintInput {
            LeaderHitnInputView(vm: vm.leaderHitnInputVM)
                .padding(.horizontal, 8)
        } else {
            EmptyView()
        }
    }
    
    // MARK: Functions
    
    private func prepareVotes(_ state: GState) -> [Int: [Player]] {
        func map(team: Team) -> [Int: [Player]] {
            let players = team.players
            let votes = team.votes
            
            var result: [Int: [Player]] = [:]
            
            for vote in votes {
                if let player = players.first(where: { $0.id == vote.playerId }) {
                    if result[vote.wordIndex] == nil {
                        result[vote.wordIndex] = [player]
                    } else {
                        result[vote.wordIndex]?.append(player)
                    }
                }
            }
            
            return result
        }
        
        if state.phase == .red {
            return map(team: state.teams[0])
        } else if state.phase == .blue {
            return map(team: state.teams[1])
        } else {
            return [:]
        }
    }
    
    private func prepare() {
        isLoading = true
        Task { @MainActor in
            self.state = try! await vm.start { state in
                Task { @MainActor in
                    self.state = state
                }
            }
            isLoading = false
        }
    }
}

private extension Phase {
    var title: String {
        switch self {
        case .idle: return "Собираем команды"
        case .redLeader: return "Красные загадывают слово"
        case .red: return "Ходят красные"
        case .blueLeader: return "Синие загадывают слово"
        case .blue: return "Ходят синие"
        case .endRed: return "Победа красных"
        case .endBlue: return "Победа синих"
        }
    }
}
