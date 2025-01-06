//
//  IGameService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

protocol IGameService: Sendable {
    func add(game: Game) async throws
    func join(gameId: String, player: Game.Player) async throws -> Game.State
    func game(by id: String) async throws -> Game.State

    func connect(to gameId: String, playerId: String, ws: WebSocket, on req: Request) async throws -> HTTPStatus
    
    func all() async throws -> [String]
    func reset() async throws
    func newStateFor(gameId: String, newState: Game.State) async
}

// MARK: - Storage
struct GameServiceKey: StorageKey {
    typealias Value = IGameService
}

extension Application {
    var gameService: IGameService {
        get {
            self.storage[GameServiceKey.self]!
        }
        set {
            self.storage[GameServiceKey.self] = newValue
        }
    }
}
