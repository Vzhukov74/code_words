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
                    let gameId = req.parameters.get("gameId")
                    print(gameId)
                    return try await req.view.render("cw_game")
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
