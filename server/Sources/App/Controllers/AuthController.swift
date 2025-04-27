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
    
    let password = Environment.get("PASSWORD") ?? ""
    
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
        let token = try await req.jwt.sign(payload)
        
        try await req.redis.set("app.solitaire.auth.key", toJSON: token)

        return ClientTokenResponse(token: token)
    }
}
