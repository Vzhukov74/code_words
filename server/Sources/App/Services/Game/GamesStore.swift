//
//  File.swift
//  code_word_server
//
//  Created by Владислав Жуков on 13.11.2024.
//


actor GamesStore {
    private var games: [String: Game] = [:]
    
    func game(by id: String) -> Game? {
        games[id]
    }
    
    func add(game: Game, by id: String) {
        games[id] = game
    }
    
    func remove(by id: String) {
        games.removeValue(forKey: id)
    }
}
