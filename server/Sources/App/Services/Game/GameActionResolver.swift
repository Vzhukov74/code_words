//
//  GameActionResolver.swift
//  code_word_server
//
//  Created by Владислав Жуков on 13.11.2024.
//

struct GameActionResolver {
    
    let state: Game.State
    let userId: String
    let hostId: String
    
    func resolve(cmd: Cmd) -> Game.State? {
        switch cmd {
        case let .start(dictionary):
            return start(dictionary: dictionary)
        case let .joinTeam(teamStr):
            guard let team = Team(rawValue: teamStr) else { return nil }
            return joun(team: team)
        case let .becameTeamLeader(teamStr):
            guard let team = Team(rawValue: teamStr) else { return nil }
            return becameTeamLeader(team: team)
        case let .selectWord(wordIndexStr):
            guard let wordIndex = Int(wordIndexStr) else { return nil }
            return selectWord(wordIndex: wordIndex)
        case let .writeDownWord(word, number):
            return writeDownWord(word: word, numberStr: number)
        case let .endTurn:
            return handleEndTurn()
        case .restart:
            return restart()
        }
    }
    
    func start(dictionary: String) -> Game.State? {
        guard hostId == userId else { return nil }
        guard state.phase == .idle else { return nil }
        
        var state = state
        
        let words = WordsProvider(dictionary: .common).words()
        let redWords = words.filter({ $0.color == .red }).count
        
        state.words = words
        state.phase = redWords == 9 ? .redLeader : .blueLeader
        
        // red team
        state.teams[0].countWords = redWords
        state.teams[0].openWords = 0
        
        // blue team
        state.teams[1].countWords = redWords == 9 ? 8 : 9
        state.teams[1].openWords = 0
        
        return state
    }
    
    func joun(team: Team) -> Game.State? {
        guard state.phase == .idle else { return nil }

        var state = state
        let teamIndex = team.teamIndex // index to join
        let oppositeTeamIndex = team.oppositeTeamIndex
        
        // find currnent user team to move him to new team
        guard let player = findAndRemovePlayerFromTeam(
            state: &state,
            teamIndex: teamIndex,
            oppositeTeamIndex: oppositeTeamIndex
        ) else { return nil }
        
        state.teams[teamIndex].players.append(player)
        
        return state
    }
    
    func becameTeamLeader(team: Team) -> Game.State? {
        guard state.phase == .idle else { return nil }

        var state = state
        let teamIndex = team.teamIndex // index to join
        let oppositeTeamIndex = team.oppositeTeamIndex
        
        // find currnent user team to move him to new team
        guard let player = findAndRemovePlayerFromTeam(
            state: &state,
            teamIndex: teamIndex,
            oppositeTeamIndex: oppositeTeamIndex
        ) else { return nil }
        
        state.teams[teamIndex].leader = player
        
        return state
    }
    
    func selectWord(wordIndex: Int) -> Game.State? {
        guard state.phase == .red || state.phase == .blue else { return nil }
        guard let teamIndex = state.phase.teamIndex else { return nil }
        
        var state = state
        
        let vote = Game.Vote(playerId: userId, wordIndex: wordIndex)
        
        if let voteIndex = state.teams[teamIndex].votes.firstIndex(where: { $0.playerId == userId }) {
            state.teams[teamIndex].votes.remove(at: voteIndex)
        }
        
        state.teams[teamIndex].votes.append(vote)
        
        return handleVote(state: state, teamIndex: teamIndex)
    }
    
    func writeDownWord(word: String, numberStr: String) -> Game.State? {
        guard state.phase == .blueLeader || state.phase == .redLeader else { return nil }
        guard let teamIndex = state.phase.teamIndex else { return nil }
        guard let number = Int(numberStr) else { return nil }
        
        var state = state
        
        let word = Game.Hint(
            word: word,
            number: number,
            numberOfOpenWords: 0
        )
        
        state.teams[teamIndex].words.append(word)
        
        return state
    }
    
    func handleEndTurn() -> Game.State? {
        guard state.phase == .red || state.phase == .blue else { return nil }
        guard let teamIndex = state.phase.teamIndex else { return nil }
        guard let player = state.teams[teamIndex].players.first(where: { $0.id == userId }) else { return nil }
        
        var state = state
        
        state.teams[teamIndex].endTurn.append(player)
        
        if state.teams[teamIndex].endTurn.count == state.teams[teamIndex].players.count {
            state.teams[teamIndex].endTurn = []
            return onNextPhase(state: state)
        } else {
            return state
        }
    }
    
    func restart() -> Game.State {
        var state = state
        state.words = []
        state.phase = .idle
        
        // red team
        state.teams[0].countWords = 0
        state.teams[0].openWords = 0
        state.teams[0].words = []
        state.teams[0].votes = []
        state.teams[0].endTurn = []
        
        // blue team
        state.teams[1].countWords = 0
        state.teams[1].openWords = 0
        state.teams[1].words = []
        state.teams[1].votes = []
        state.teams[1].endTurn = []
        
        return state
    }
    
    // MARK: Private
    
    /// find and remove player from team
    /// teamIndex it is index to join, oppositeTeamIndex it is index from witch team player gonna leave
    private func findAndRemovePlayerFromTeam(state: inout Game.State, teamIndex: Int, oppositeTeamIndex: Int) -> Game.Player? {
        // handle oppositeTeam
        if (state.teams[oppositeTeamIndex].leader?.id ?? "") == userId { // player is leader of oppositeTeam
            let player = state.teams[oppositeTeamIndex].leader
            state.teams[oppositeTeamIndex].leader = nil
            return player
        }
        if let index = state.teams[oppositeTeamIndex].players.firstIndex(where: { $0.id == userId }) {
            return state.teams[oppositeTeamIndex].players.remove(at: index)
        }
        // handle team to join
        if (state.teams[teamIndex].leader?.id ?? "") == userId { // player is leader of oppositeTeam
            let player = state.teams[teamIndex].leader
            state.teams[teamIndex].leader = nil
            return player
        }
        if let index = state.teams[teamIndex].players.firstIndex(where: { $0.id == userId }) {
            return state.teams[teamIndex].players.remove(at: index)
        }

        return nil
    }
    
    /// handle votes
    private func handleVote(state: Game.State, teamIndex: Int) -> Game.State? {
        let playersCount = state.teams[teamIndex].players.count

        // key is word index | value is votes counter
        var votes: [Int: Int] = [:]

        state.teams[teamIndex].votes.forEach {
            votes[$0.wordIndex] = (votes[$0.wordIndex] ?? 0) + 1
        }

        for wordIndex in votes.keys where (votes[wordIndex] ?? 0) == playersCount {
            // open word and handle next move
            return openWord(state: state, wordIndex: wordIndex, teamIndex: teamIndex)
        }

        return state
    }
    
    private func openWord(state: Game.State, wordIndex: Int, teamIndex: Int) -> Game.State? {
        var state = state
        
        state.teams[teamIndex].votes = []
        state.words[wordIndex].isOpen = true
        
        let hintIndex = state.teams[teamIndex].words.endIndex
        let color = state.words[wordIndex].color
        let colorIndex = color.index
        
        if colorIndex == teamIndex { // team open right word
            state.teams[teamIndex].words[hintIndex].numberOfOpenWords += 1
            state.teams[teamIndex].openWords += 1
            
            if state.teams[teamIndex].openWords == state.teams[teamIndex].countWords { // team won
                return endGame(state: state, teamIndex: teamIndex)
            } else {
                if state.teams[teamIndex].words[hintIndex].numberOfOpenWords == state.teams[teamIndex].words[hintIndex].number {
                    return onNextPhase(state: state)
                } else {
                    return state
                }
            }
        } else if color == .black { // team open black (end of the game)
            return endGame(state: state, teamIndex: teamIndex == 0 ? 1 : 0)
        } else { // team open wrong word
            return onNextPhase(state: state)
        }
    }
    
    private func onNextPhase(state: Game.State) -> Game.State? {
        var state = state
        
        switch state.phase {
        case .blue:
            state.phase = .redLeader
            return state
        case .blueLeader:
            state.phase = .blue
            return state
        case .red:
            state.phase = .blueLeader
            return state
        case .redLeader:
            state.phase = .red
            return state
        default:
            return nil
        }
    }
    
    private func endGame(state: Game.State, teamIndex: Int) -> Game.State {
        var state = state
        
        if teamIndex == 0 {
            state.phase = .endRed
        } else {
            state.phase = .endBlue
        }
    
        return state
    }
}
