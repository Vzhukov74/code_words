//
//  FrontController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 03.01.2025.
//

import Vapor

final class FrontController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get { req async throws in
            try await req.view.render("root")
        }
        
        routes.group(WebAdminMiddleware()) { group in
            group.group("games") { games in
                games.get("list") { req async throws -> View in
                    let games = try await req.application.gameService.all()
                    return try await req.view.render("cw_game_list", GameList(games: games))
                }
                games.get("detail", ":gameId") { req async throws -> View in
                    guard let id = req.parameters.get("gameId") else {
                        throw Abort(.badRequest)
                    }
                    let state = try await req.application.gameService.game(by: id)
                    
                    return try await req.view.render("cw_game", GameDetail(state: state))
                }
            }
        }
    }
}

private struct WebAdminMiddleware: AsyncMiddleware {
    let code = "WebAdmin"
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let cookie = request.cookies[code], cookie.string == code else {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}

private struct GameList: Codable {
    let games: [String]
}

private struct GameDetail: Codable {
    let redLeader: String
    let blueLeader: String
    let redPlayers: [String]
    let bluePlayers: [String]
    let wordsIndexes: [String]
    let phase: String
    let id: String
    
    init(state: Game.State) {
        var redPlayers: [String] = []
        var bluePlayers: [String] = []
        
        for player in state.teams[0].players {
            redPlayers.append(player.id)
        }
        for player in state.teams[1].players {
            bluePlayers.append(player.id)
        }

        let redLeaderObj = state.teams[0].leader
        let blueLeaderObj = state.teams[1].leader
        
        self.redLeader = redLeaderObj?.id ?? "empty"
        self.blueLeader = blueLeaderObj?.id ?? "empty"
        self.redPlayers = redPlayers
        self.bluePlayers = bluePlayers
        self.phase = state.phase.rawValue
        self.wordsIndexes = (0..<25).compactMap { String($0) }
        self.id = state.id
    }
}
