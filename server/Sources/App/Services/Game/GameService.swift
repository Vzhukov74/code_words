//
//  GameService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

struct WebSocketContext {
    let webSocket: WebSocket
    let request: Request
}

final class GameService: IGameService {
    private var games: [String: Game] = [:]
    
    func add(game: Game, on req: Request) throws -> EventLoopFuture<Void> {
        self.games[game.id] = game
        return req.eventLoop.makeSucceededFuture(())
    }
    
    func join(gameId: String, player: Game.Player, on req: Request) throws -> EventLoopFuture<Void> {
        self.games[gameId]?.join(player: player)
        return req.eventLoop.makeSucceededFuture(())
    }
    
    func game(by id: String, on req: Request) throws -> EventLoopFuture<Game.State> {
        let game = games[id]!
        return req.eventLoop.makeSucceededFuture(game.state)
    }
    
    func connect(to gameId: String, playerId: String, ws: WebSocket, on req: Request) throws -> EventLoopFuture<Void> {
        guard let game = self.games[gameId] else {
            throw Abort(.badRequest, reason: "game don't exist")
        }
        
        guard game.isPlaying(player: playerId) == true else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }
        
        let wsContext = WebSocketContext(webSocket: ws, request: req)
        games[gameId]?.setContext(wsContext, forPlayer: playerId)

        ws.pingInterval = .seconds(5)
        ws.onText { [unowned self] ws, text in
            req.logger.debug("\(text)")
            
            ws.send("1234")
//            let reqId = UUID()
//            req.logger.debug("[\(reqId)]: \(text)")
//            guard let game = self.games[gameId] else { return }
//
//            guard let context = game.context(forUser: userId) else {
//                req.logger.debug("[\(reqId)]: Invalid command")
//                ws.send(error: .invalidCommand, fromUser: userId)
//                return
//            }
//
//            do {
//                let message = try GameClientMessage(from: text)
//                let resolver = try GameActionResolver(game: game, userId: userId, message: message)
//                resolver.resolve { [unowned self] result in
//                    switch result {
//                    case .success(let result):
//                        do {
//                            try self.handle(result: result, context: context, game: game)
//                        } catch {
//                            handle(error: error, userId: userId, game: game)
//                        }
//                    case .failure(let error):
//                        self.handleServerError(error: error, userId: userId, game: game)
//                    }
//                }
//            } catch {
//                self.handle(error: error, userId: userId, game: game)
//            }
        }
        _ = ws.onClose.always { [unowned self] _ in
            guard let game = self.games[gameId] else { return }
            //game.state.userDidDisconnect(userId)
            
//            if game.state.host.id == userId {
//                req.eventLoop.scheduleTask(in: .minutes(5)) {
//                    ExpiredGameJob(id: matchId)
//                        .invoke(req.application)
//                }
//            }
        }
        return req.eventLoop.makeSucceededFuture(())
    }
    
    // MARK: helpers
    
    func games(on req: Request) throws -> EventLoopFuture<[String]> {
        req.eventLoop.next().future(Array(games.values).map { $0.id })
    }
    
    func players(gameId: String, on req: Request) throws -> EventLoopFuture<[Game.Player]> {
        if let game = self.games[gameId] {
            var players = game.state.allPlayers
            return req.eventLoop.next().future(players)
        } else {
            return req.eventLoop.next().future([])
        }
    }
}
