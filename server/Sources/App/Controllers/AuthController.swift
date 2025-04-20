//
//  AuthController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.04.2025.
//

import Vapor

actor AuthController: RouteCollection {
    private struct LoginRequest: Codable {
        let login: String
        let password: String
    }
    
    private let password = "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
    
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.group("auth") { route in
            route.post("login", use: login)
        }
        
        routes.get("auth") { req async throws -> View in
            return try await req.view.render("auth")
        }
    }

    @Sendable private func login(req: Request) async throws -> ClientTokenResponse {
        let loginData = try req.content.decode(LoginRequest.self, as: .json)
        
        guard loginData.password == password else { throw Abort(.badRequest) }
        
        let payload = SessionToken(userId: loginData.login)
        return ClientTokenResponse(token: try await req.jwt.sign(payload))
    }
}
