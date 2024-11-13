//
//  GameService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

final class GameService: IGameService {
    private let gamesStore = GamesStore()
    
    func add(game: Game) async throws {
        await gamesStore.add(game: game, by: game.id)
    }
    
    func join(gameId: String, player: Game.Player) async throws -> Game.State {
        guard let game = await gamesStore.game(by: gameId) else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }
        
        guard await !game.isPlaying(player: player.id) else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }
        
        await game.join(player: player)

        let state = await game.state()
        
        return state
    }
    
    func game(by id: String) async throws -> Game.State {
        guard let game = await gamesStore.game(by: id) else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }

        return await game.state()
    }
    
    func connect(to gameId: String, playerId: String, ws: WebSocket, on req: Request) async throws -> HTTPStatus {
        guard let game = await gamesStore.game(by: gameId) else {
            throw Abort(.badRequest, reason: "game don't exist")
        }
        
        guard await game.isPlaying(player: playerId) == true else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }
        
        let wsContext = WebSocketContext(webSocket: ws, request: req)
        await game.setContext(wsContext, forPlayer: playerId)

        ws.pingInterval = .seconds(5)
        ws.onText { ws, text in
            guard let cmd = Cmd(rawValue: text) else { return }
            let state = await game.state()
            guard let newState = GameActionResolver(state: state, userId: playerId, hostId: game.hostId).resolve(cmd: cmd) else { return }
            await game.new(state: newState)
        }
        _ = ws.onClose.always { _ in }

        return .ok
    }
}
