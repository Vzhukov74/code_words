//
//  AdminMiddleware.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 27.04.2025.
//

import Vapor

final class AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        if let authKey = request.cookies["auth"]?.string {
            if let key = try? await request.redis.get("app.solitaire.auth.key", asJSON: String.self), key == authKey {
                return try await next.respond(to: request)
            } else {
                return request.redirect(to: "../../auth")
            }
        } else {
            return request.redirect(to: "../../auth")
        }
    }
}
